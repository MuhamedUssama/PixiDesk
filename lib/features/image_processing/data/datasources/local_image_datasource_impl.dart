import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';
import '../services/image_output_writer.dart';
import '../services/image_worker.dart';
import '../services/text_watermark_renderer.dart';
import 'local_image_datasource.dart';

@LazySingleton(as: LocalImageDataSource)
class LocalImageDataSourceImpl implements LocalImageDataSource {
  final _writer = ImageOutputWriter();
  @override
  Future<ImageEntity> inspect(String path, ImageCancellation cancellation) =>
      runImageWorker<ImageEntity>(ImageWorkerTask(path), cancellation);

  Future<void> _validateSource(ImageEntity source) async {
    final stat = await File(source.path).stat();
    if (stat.size != source.sizeInBytes ||
        stat.modified.microsecondsSinceEpoch != source.modifiedMicros) {
      throw const ImageFailure(ImageFailureCode.sourceChanged);
    }
  }

  @override
  Future<Uint8List> preview(
    ImageEntity source,
    ImageRecipe recipe,
    ImageCancellation cancellation,
  ) async {
    await _validateSource(source);
    final text = await renderTextWatermark(recipe.watermarkText);
    final rendered = await runImageWorker<EncodedImage>(
      ImageWorkerTask(source.path, recipe: recipe, textWatermark: text),
      cancellation,
    );
    return rendered.thumbnail;
  }

  @override
  Future<ImageResult> process(
    ImageRequest request,
    ImageCancellation cancellation,
  ) async {
    final clock = Stopwatch()..start();
    request.recipe.validate();
    final source = request.source;
    await _validateSource(source);
    final format = request.recipe.format.canonical;
    final ext = p
        .extension(request.destinationPath)
        .replaceFirst('.', '')
        .toLowerCase();
    // Never reinterpret the destination as a different codec.
    if (ImageFormat.fromPath('image.$ext').canonical != format) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    final text = await renderTextWatermark(request.recipe.watermarkText);
    final rendered = await runImageWorker<EncodedImage>(
      ImageWorkerTask(source.path, recipe: request.recipe, textWatermark: text),
      cancellation,
    );
    await _validateSource(source);
    cancellation.check();
    var bytes = rendered.bytes;
    final notices = [...rendered.notices];
    final r = request.recipe;
    final originalAllowed =
        request.keepSmaller &&
        source.format.canonical == format &&
        r ==
            ImageRecipe(
              format: format,
              quality: r.quality,
              minQuality: r.minQuality,
              metadata: MetadataPolicy.preserve,
              webpLossless: r.webpLossless,
            );
    if (bytes.length >= source.sizeInBytes) {
      if (originalAllowed) {
        bytes = await File(source.path).readAsBytes();
        notices.add(ImageNotice.unchanged);
      } else if (request.keepSmaller) {
        notices.add(ImageNotice.noSavings);
      }
    }
    final path = await _writer.write(
      source: source.path,
      protectedPaths: request.protectedPaths,
      destination: request.destinationPath,
      bytes: bytes,
      conflict: request.conflict,
      cancellation: cancellation,
    );
    return ImageResult(
      path: path ?? request.destinationPath,
      originalBytes: source.sizeInBytes,
      outputBytes: path == null ? 0 : bytes.length,
      width: rendered.width,
      height: rendered.height,
      elapsed: clock.elapsed,
      thumbnail: notices.contains(ImageNotice.unchanged)
          ? source.thumbnail
          : rendered.thumbnail,
      notices: List.unmodifiable(notices),
      skipped: path == null,
    );
  }
}
