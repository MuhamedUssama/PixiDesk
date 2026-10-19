import 'package:injectable/injectable.dart';
import '../entities/image_failure.dart';
import '../entities/image_job.dart';
import 'process_image_usecase.dart';

@lazySingleton
class CompressImageUseCase {
  final ProcessImageUseCase _process;
  CompressImageUseCase(this._process);
  Future<ImageResult> call(ImageRequest request, ImageCancellation token) =>
      _process(
        ImageRequest(
          source: request.source,
          recipe: request.recipe,
          destinationPath: request.destinationPath,
          conflict: request.conflict,
          keepSmaller: true,
          protectedPaths: request.protectedPaths,
        ),
        token,
      );
}
