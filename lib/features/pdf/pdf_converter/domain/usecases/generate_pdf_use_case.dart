import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/pdf_image_item.dart';
import '../entities/pdf_config.dart';
import '../repositories/pdf_repository.dart';

@injectable
class GeneratePdfUseCase {
  final PdfRepository _repository;

  GeneratePdfUseCase(this._repository);

  Future<File> call({
    required List<PdfImageItem> images,
    required PdfConfig config,
    required String outputPath,
  }) {
    return _repository.generatePdf(
      images: images,
      config: config,
      outputPath: outputPath,
    );
  }
}
