import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';

@lazySingleton
class CancelConversionUseCase {
  final PdfToImageRepository _repository;

  CancelConversionUseCase(this._repository);

  Future<void> call() async {
    return _repository.cancelCurrentConversion();
  }
}
