import 'dart:typed_data';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';

abstract interface class LocalImageDataSource {
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
