import 'package:injectable/injectable.dart';
import '../entities/image_failure.dart';
import '../entities/image_job.dart';
import 'process_image_usecase.dart';

@lazySingleton
class ConvertImageUseCase {
  final ProcessImageUseCase _process;
  ConvertImageUseCase(this._process);
  Future<ImageResult> call(ImageRequest request, ImageCancellation token) =>
      _process(request, token);
}
