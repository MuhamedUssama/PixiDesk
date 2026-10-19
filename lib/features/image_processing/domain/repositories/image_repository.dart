import 'dart:typed_data';
import '../entities/image_entity.dart';
import '../entities/image_failure.dart';
import '../entities/image_job.dart';
import '../entities/image_recipe.dart';

abstract class ImageRepository {
  Future<ImageEntity> inspect(String path, ImageCancellation cancellation);
  Future<ImageResult> process(
    ImageRequest request,
    ImageCancellation cancellation,
  );
  Future<Uint8List> preview(
    ImageEntity source,
    ImageRecipe recipe,
    ImageCancellation cancellation,
  );
}
