import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/pdf_to_image/data/pdfium/pdf_image_exporter.dart';
import 'package:pixi_desk/features/pdf/shared/domain/entities/pdf_processing_failure.dart';

void main() {
  late Directory fixtures;
  late Directory output;
  setUp(() async {
    fixtures = await Directory.systemTemp.createTemp('pdf_export_test_');
    output = await Directory(path.join(fixtures.path, 'out')).create();
  });
  tearDown(() => fixtures.delete(recursive: true));
  Future<File> createImage(String name, String format) async {
    final pixels = image_codec.Image(width: 12, height: 8);
    image_codec.fill(pixels, color: image_codec.ColorRgb8(255, 0, 0));
    final bytes = switch (format) {
      'tiff' => image_codec.encodeTiff(pixels),
      'jpg' => image_codec.encodeJpg(pixels),
      _ => image_codec.encodePng(pixels),
    };
    return File(path.join(fixtures.path, name))..writeAsBytesSync(bytes);
  }

  for (final format in ['png', 'jpg', 'tiff']) {
    test(
      'rotates $format while retaining its codec and source bytes',
      () async {
        final source = await createImage('page.$format', format);
        final original = await source.readAsBytes();
        await exportPdfImages(
          PdfFileExportRequest(
            mode: PdfFileExportMode.images,
            destination: output.path,
            images: [source.path],
            rotations: {source.path: 1},
          ),
        );
        final result = File(
          path.join(output.path, path.basename(source.path)),
        ).readAsBytesSync();
        final decoded = image_codec.decodeImage(result)!;
        expect(decoded.width, 8);
        expect(decoded.height, 12);
        expect(image_codec.findDecoderForData(result)!.format.name, format);
        expect(source.readAsBytesSync(), original);
      },
    );
  }
  test(
    'preserves existing files and symlink targets with collision-safe names',
    () async {
      final source = await createImage('page.png', 'png');
      final existing = File(path.join(output.path, 'page.png'))
        ..writeAsStringSync('existing');
      final target = File(path.join(fixtures.path, 'protected'))
        ..writeAsStringSync('protected');
      await Link(path.join(output.path, 'page_1.png')).create(target.path);
      await exportPdfImages(
        PdfFileExportRequest(
          mode: PdfFileExportMode.images,
          destination: output.path,
          images: [source.path],
        ),
      );
      expect(existing.readAsStringSync(), 'existing');
      expect(target.readAsStringSync(), 'protected');
      expect(File(path.join(output.path, 'page_2.png')).existsSync(), isTrue);
      expect(output.listSync().whereType<Directory>(), isEmpty);
    },
    skip: Platform.isWindows
        ? 'Symlink creation requires additional Windows privileges.'
        : false,
  );
  test(
    'archive deduplicates entry names and preserves existing destination archives',
    () async {
      final first = await createImage('page.png', 'png');
      final nested = await Directory(
        path.join(fixtures.path, 'nested'),
      ).create();
      final second = await first.copy(path.join(nested.path, 'page.png'));
      final destination = File(path.join(output.path, 'result.zip'))
        ..writeAsStringSync('existing');
      await exportPdfImages(
        PdfFileExportRequest(
          mode: PdfFileExportMode.archive,
          destination: destination.path,
          images: [first.path, second.path],
          rotations: {second.path: 1},
        ),
      );
      expect(destination.readAsStringSync(), 'existing');
      final archive = ZipDecoder().decodeBytes(
        File(path.join(output.path, 'result_1.zip')).readAsBytesSync(),
      );
      expect(archive.files.map((entry) => entry.name), [
        'page.png',
        'page_1.png',
      ]);
      expect(image_codec.decodePng(archive.files.last.content)!.width, 8);
    },
  );
  test(
    'failed writes remove staging directories and preserve existing output',
    () async {
      final existing = File(path.join(output.path, 'missing.png'))
        ..writeAsStringSync('existing');
      await expectLater(
        exportPdfImages(
          PdfFileExportRequest(
            mode: PdfFileExportMode.images,
            destination: output.path,
            images: [path.join(fixtures.path, 'missing.png')],
          ),
        ),
        throwsA(isA<PdfProcessingFailure>()),
      );
      expect(output.listSync().length, 1);
      expect(existing.readAsStringSync(), 'existing');
    },
  );
  test('documents with matching names get separate archives', () async {
    final source = await createImage('page.png', 'png');
    await exportPdfImages(
      PdfFileExportRequest(
        mode: PdfFileExportMode.separateArchives,
        destination: output.path,
        groupedImages: {
          '/first/doc.pdf': [source.path],
          '/second/doc.pdf': [source.path],
        },
      ),
    );
    expect(File(path.join(output.path, 'doc.zip')).existsSync(), isTrue);
    expect(File(path.join(output.path, 'doc_1.zip')).existsSync(), isTrue);
  });
}
