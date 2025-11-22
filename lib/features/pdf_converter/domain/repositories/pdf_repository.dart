import 'dart:io';
import '../entities/pdf_image_item.dart';
import '../entities/pdf_config.dart';

abstract class PdfRepository {
  Future<File> generatePdf({
    required List<PdfImageItem> images,
    required PdfConfig config,
    required String outputPath,
  });
}
