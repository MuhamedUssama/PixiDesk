import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_output_name.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/process_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/convert_image_usecase.dart';
import '../../support/fakes.dart';

void main() {
  test('validates options before any repository IO', () {
    final repository = FakeImageRepository();
    final usecase = ConvertImageUseCase(ProcessImageUseCase(repository));
    expect(
      () => usecase(
        ImageRequest(
          source: asset('/a.png'),
          recipe: const ImageRecipe(quality: 0),
          destinationPath: '/out.png',
        ),
        ImageCancellation(),
      ),
      throwsA(isA<ImageFailure>()),
    );
    expect(repository.requests, isEmpty);
  });
  test('cancelled requests cannot start processing', () {
    final repository = FakeImageRepository();
    final usecase = ProcessImageUseCase(repository);
    final token = ImageCancellation()..cancel();
    expect(
      () => usecase(
        ImageRequest(
          source: asset('/a.png'),
          recipe: const ImageRecipe(),
          destinationPath: '/out.png',
        ),
        token,
      ),
      throwsA(isA<ImageFailure>()),
    );
    expect(repository.requests, isEmpty);
  });
  test(
    'JPG JPEG and uppercase aliases share one codec; unknown is explicit',
    () {
      expect(ImageFormat.fromPath('/dir/photo.JPEG'), ImageFormat.jpg);
      expect(ImageFormat.fromPath('/dir/photo.tif'), ImageFormat.tiff);
      expect(ImageFormat.fromPath('/dir/photo.heic'), ImageFormat.unknown);
      expect(ImageFormat.outputFormats, isNot(contains(ImageFormat.jpeg)));
      expect(ImageFormat.outputFormats, isNot(contains(ImageFormat.unknown)));
    },
  );
  test(
    'naming preserves dots and Arabic and rejects path traversal/unknown tokens',
    () {
      final source = asset('/صور/photo.final.v2.png');
      expect(
        ImageOutputName.build(
          '{name}_{index}',
          source,
          const ImageRecipe(format: ImageFormat.jpg),
          0,
        ),
        'photo.final.v2_001.jpg',
      );
      expect(
        ImageOutputName.build(
          '{name}',
          asset('/صورة.png'),
          const ImageRecipe(),
          0,
        ),
        'صورة.png',
      );
      expect(
        () =>
            ImageOutputName.build('../{name}', source, const ImageRecipe(), 0),
        throwsA(isA<ImageFailure>()),
      );
      expect(
        () =>
            ImageOutputName.build('{unknown}', source, const ImageRecipe(), 0),
        throwsA(isA<ImageFailure>()),
      );
    },
  );
  test(
    'nullable options can be cleared explicitly; invalid crops and NaN are rejected',
    () {
      final r = const ImageRecipe(
        width: 100,
        height: 100,
        targetBytes: 2048,
        format: ImageFormat.jpg,
      );
      final cleared = r.copyWith(
        clearWidth: true,
        clearHeight: true,
        clearTarget: true,
      );
      expect(cleared.width, isNull);
      expect(cleared.height, isNull);
      expect(cleared.targetBytes, isNull);
      expect(
        () => const ImageRecipe(cropLeft: .5).validate(),
        throwsA(isA<ImageFailure>()),
      );
      expect(
        () => ImageRecipe(brightness: double.nan).validate(),
        throwsA(isA<ImageFailure>()),
      );
      expect(
        () => const ImageRecipe(
          format: ImageFormat.png,
          targetBytes: 2048,
        ).validate(),
        throwsA(isA<ImageFailure>()),
      );
    },
  );
  test(
    'dimension tokens reflect final rotation and source braces are literal',
    () {
      expect(
        ImageOutputName.build(
          '{name}_{width}x{height}',
          asset('/{width}.png'),
          const ImageRecipe(width: 30, height: 30, quarterTurns: 1),
          0,
        ),
        '{width}_15x30.png',
      );
    },
  );
}
