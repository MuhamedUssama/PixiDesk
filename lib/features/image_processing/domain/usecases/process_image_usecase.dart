import '../entities/image_geometry.dart';
import 'package:injectable/injectable.dart';
import '../entities/image_entity.dart';
import '../entities/image_failure.dart';
import '../entities/image_job.dart';
import '../repositories/image_repository.dart';

@lazySingleton
class ProcessImageUseCase {
  final ImageRepository _repository;
  ProcessImageUseCase(this._repository);
  Future<ImageEntity> inspect(String path, ImageCancellation token) =>
      _repository.inspect(path, token);
  Future<ImageResult> call(ImageRequest request, ImageCancellation token) {
    request.recipe.validate();
    ImageGeometry.plan(request.source, request.recipe);
    token.check();
    if (request.destinationPath.trim().isEmpty) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    return _repository.process(request, token);
  }
}
