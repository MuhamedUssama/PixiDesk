import 'package:injectable/injectable.dart';
import '../repositories/pdf_to_image_repository.dart';

@injectable
class ReleasePdfConversionUseCase {
  final PdfToImageRepository _repository;
  ReleasePdfConversionUseCase(this._repository);
  Future<void> call(String jobId) => _repository.releaseConversion(jobId);
}
