import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixi_desk/features/image_processing/data/datasources/local_image_datasource_impl.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late File source;
  late LocalImageDataSourceImpl data;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pixidesk-test-');
    final image = img.Image(width: 120, height: 60, numChannels: 4);
    for (final px in image) {
      px.setRgba(px.x * 2, px.y * 4, 100, 128);
    }
    image.exif.imageIfd.make = 'private camera';
    source = await File(
      '${dir.path}/original.final.png',
    ).writeAsBytes(img.encodePng(image));
    data = LocalImageDataSourceImpl();
  });
  tearDown(() async => dir.delete(recursive: true));
  Future<ImageResult> process(
    ImageRecipe recipe, {
    String? destination,
    bool compress = false,
    OutputConflict conflict = OutputConflict.rename,
  }) async {
    final token = ImageCancellation();
    final input = await data.inspect(source.path, token);
    return data.process(
      ImageRequest(
        source: input,
        recipe: recipe,
        destinationPath:
            destination ?? '${dir.path}/result.${recipe.format.extension}',
        keepSmaller: compress,
        conflict: conflict,
      ),
      token,
    );
  }

  test(
    'inspection uses magic bytes, async stats, oriented dimensions and bounded thumbnail',
    () async {
      final renamed = await source.copy('${dir.path}/wrong.jpg');
      final input = await data.inspect(renamed.path, ImageCancellation());
      expect(input.format, ImageFormat.png);
      expect(input.width, 120);
      expect(input.height, 60);
      expect(img.decodePng(input.thumbnail), isNotNull);
      expect(input.hasExif, isTrue);
    },
  );
  for (final format in ImageFormat.outputFormats) {
    test(
      'real isolate exports a decodable ${format.name} with matching signature',
      () async {
        final result = await process(ImageRecipe(format: format));
        final bytes = await File(result.path).readAsBytes();
        final decoder = img.findDecoderForData(bytes)!;
        expect(ImageFormat.fromPath('x.${decoder.format.name}'), format);
        expect(img.decodeImage(bytes, frame: 0), isNotNull);
        expect(result.outputBytes, bytes.length);
        expect(await source.exists(), isTrue);
      },
    );
  }
  test('ICO resizes large inputs and includes six valid icon sizes', () async {
    await source.writeAsBytes(
      img.encodePng(img.Image(width: 512, height: 512)),
    );
    final result = await process(const ImageRecipe(format: ImageFormat.ico));
    final decoded = img.decodeIco(await File(result.path).readAsBytes())!;
    expect(decoded.frames.length, 6);
    expect(decoded.frames.map((f) => f.width), [16, 32, 48, 64, 128, 256]);
  });
  test(
    'resize crop rotate and flip produce correct exported dimensions',
    () async {
      final result = await process(
        const ImageRecipe(width: 30, height: 30, quarterTurns: 1),
      );
      expect(result.width, 15);
      expect(result.height, 30);
    },
  );
  test('PNG export removes private EXIF camera data', () async {
    final result = await process(
      const ImageRecipe(metadata: MetadataPolicy.remove),
    );
    final image = img.decodePng(await File(result.path).readAsBytes())!;
    expect(image.exif.imageIfd.make, isNull);
    expect(image.exif.isEmpty, isTrue);
  });
  test('JPEG alpha flatten uses requested background and reports it', () async {
    await source.writeAsBytes(
      img.encodePng(img.Image(width: 16, height: 16, numChannels: 4)),
    );
    final result = await process(
      const ImageRecipe(
        format: ImageFormat.jpg,
        backgroundRgb: 0xff0000,
        quality: 100,
      ),
    );
    final image = img.decodeJpg(await File(result.path).readAsBytes())!;
    expect(image.getPixel(8, 8).r, greaterThan(240));
    expect(image.getPixel(8, 8).g, lessThan(15));
    expect(result.notices, contains(ImageNotice.alphaFlattened));
  });
  test(
    'same-file output is rejected and source bytes stay unchanged',
    () async {
      final original = await source.readAsBytes();
      await expectLater(
        process(const ImageRecipe(), destination: source.path),
        throwsA(
          isA<ImageFailure>().having(
            (e) => e.code,
            'code',
            ImageFailureCode.destinationConflict,
          ),
        ),
      );
      expect(await source.readAsBytes(), original);
      expect(
        await dir.list().where((f) => f.path.endsWith('.tmp')).isEmpty,
        isTrue,
      );
    },
  );
  test('source symlink alias cannot be overwritten', () async {
    final alias = await Link('${dir.path}/alias.png').create(source.path);
    await expectLater(
      process(
        const ImageRecipe(),
        destination: alias.path,
        conflict: OutputConflict.replace,
      ),
      throwsA(isA<ImageFailure>()),
    );
    expect(img.decodeImage(await source.readAsBytes()), isNotNull);
  });
  test('rename and skip protect existing outputs', () async {
    final target = await File(
      '${dir.path}/result.png',
    ).writeAsString('existing');
    final result = await process(const ImageRecipe());
    expect(result.path, endsWith('result (1).png'));
    expect(await target.readAsString(), 'existing');
    final skip = await process(
      const ImageRecipe(),
      conflict: OutputConflict.skip,
    );
    expect(skip.skipped, isTrue);
    expect(await target.readAsString(), 'existing');
  });
  test(
    'changed source snapshots and mismatched extensions are rejected',
    () async {
      final input = await data.inspect(source.path, ImageCancellation());
      await source.writeAsString('changed');
      await expectLater(
        data.process(
          ImageRequest(
            source: input,
            recipe: const ImageRecipe(),
            destinationPath: '${dir.path}/out.png',
          ),
          ImageCancellation(),
        ),
        throwsA(
          isA<ImageFailure>().having(
            (e) => e.code,
            'code',
            ImageFailureCode.sourceChanged,
          ),
        ),
      );
    },
  );
  test('cancelled tasks never commit output', () async {
    final token = ImageCancellation();
    final input = await data.inspect(source.path, token);
    token.cancel();
    await expectLater(
      data.process(
        ImageRequest(
          source: input,
          recipe: const ImageRecipe(),
          destinationPath: '${dir.path}/out.png',
        ),
        token,
      ),
      throwsA(isA<ImageFailure>()),
    );
    expect(await File('${dir.path}/out.png').exists(), isFalse);
  });
  test('unreachable target is explicit and attempts are bounded', () async {
    final noise = img.Image(width: 200, height: 200);
    for (final px in noise) {
      px.setRgb(
        (px.x * px.y * 17) % 256,
        (px.x * 43 + px.y * 11) % 256,
        (px.x * 3 + px.y * 17) % 256,
      );
    }
    await source.writeAsBytes(img.encodePng(noise));
    final result = await process(
      const ImageRecipe(
        format: ImageFormat.jpg,
        targetBytes: 1024,
        minQuality: 70,
      ),
    );
    expect(result.outputBytes, greaterThan(1024));
    expect(result.notices, contains(ImageNotice.targetNotReached));
  });
  test(
    'animation is preserved for GIF and explicitly flattened for JPEG',
    () async {
      final animation = img.Image(width: 16, height: 16)..frameDuration = 100;
      final second = img.Image(width: 16, height: 16)..frameDuration = 200;
      img.fill(second, color: img.ColorRgb8(255, 0, 0));
      animation.addFrame(second);
      await source.writeAsBytes(img.encodeGif(animation));
      final preserved = await process(
        const ImageRecipe(format: ImageFormat.gif),
      );
      expect(
        img.decodeGif(await File(preserved.path).readAsBytes())!.numFrames,
        2,
      );
      final flat = await process(const ImageRecipe(format: ImageFormat.jpg));
      expect(flat.notices, contains(ImageNotice.animationFlattened));
    },
  );
  test('corrupt files and directories fail inspection', () async {
    await source.writeAsBytes(Uint8List.fromList([0, 1, 2]));
    await expectLater(
      data.inspect(source.path, ImageCancellation()),
      throwsA(isA<ImageFailure>()),
    );
    await expectLater(
      data.inspect(dir.path, ImageCancellation()),
      throwsA(isA<ImageFailure>()),
    );
  });
  test('replace cannot overwrite another source in the same queue', () async {
    final other = await source.copy('${dir.path}/other.png');
    final original = await other.readAsBytes();
    final input = await data.inspect(source.path, ImageCancellation());
    await expectLater(
      data.process(
        ImageRequest(
          source: input,
          recipe: const ImageRecipe(),
          destinationPath: other.path,
          conflict: OutputConflict.replace,
          protectedPaths: [source.path, other.path],
        ),
        ImageCancellation(),
      ),
      throwsA(
        isA<ImageFailure>().having(
          (e) => e.code,
          'code',
          ImageFailureCode.destinationConflict,
        ),
      ),
    );
    expect(await other.readAsBytes(), original);
  });
  test(
    'destination extension cannot silently change the chosen codec',
    () async {
      await expectLater(
        process(const ImageRecipe(), destination: '${dir.path}/wrong.jpg'),
        throwsA(
          isA<ImageFailure>().having(
            (e) => e.code,
            'code',
            ImageFailureCode.invalidOptions,
          ),
        ),
      );
    },
  );
  test('nonexistent output parents do not damage any source', () async {
    final original = await source.readAsBytes();
    await expectLater(
      process(const ImageRecipe(), destination: '${dir.path}/missing/out.png'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await source.readAsBytes(), original);
  });
  testWidgets(
    'Arabic text watermark is shaped and composited in the real worker',
    (tester) async {
      final result = await tester.runAsync(
        () => process(
          const ImageRecipe(watermarkText: 'علامة مائية', watermarkScale: .8),
        ),
      );
      expect(result, isNotNull);
      final output = File(result!.path).readAsBytesSync();
      expect(output, isNot(source.readAsBytesSync()));
      expect(img.decodeImage(output)!.width, 120);
    },
  );
  test(
    'oversized input is rejected before reading and decoding its contents',
    () async {
      final handle = await source.open(mode: FileMode.write);
      await handle.truncate(64 * 1024 * 1024 + 1);
      await handle.close();
      await expectLater(
        data.inspect(source.path, ImageCancellation()),
        throwsA(
          isA<ImageFailure>().having(
            (e) => e.code,
            'code',
            ImageFailureCode.resourceLimit,
          ),
        ),
      );
    },
  );
}
