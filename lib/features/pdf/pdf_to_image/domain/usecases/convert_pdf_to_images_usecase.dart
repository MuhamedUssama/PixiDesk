import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';

@injectable
class ConvertPdfToImagesUseCase {
  final PdfToImageRepository _repository;

  ConvertPdfToImagesUseCase(this._repository);

  Stream<PdfToImageEvent> call(PdfToImageParams params) {
    return _repository.convert(params);
  }
}
