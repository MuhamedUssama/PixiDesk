import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/pdf_config.dart';
import '../../domain/entities/pdf_image_item.dart';
import '../../domain/repositories/pdf_repository.dart';

@LazySingleton(as: PdfRepository)
class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<File> generatePdf({
    required List<PdfImageItem> images,
    required PdfConfig config,
    required String outputPath,
  }) async {
    // Run PDF generation in a separate isolate
    await compute(
      _generatePdfInIsolate,
      _PdfGenerationParams(
        imagePaths: images.map((e) => e.file.path).toList(),
        config: config,
        outputPath: outputPath,
      ),
    );

    return File(outputPath);
  }
}

class _PdfGenerationParams {
  final List<String> imagePaths;
  final PdfConfig config;
  final String outputPath;

  _PdfGenerationParams({
    required this.imagePaths,
    required this.config,
    required this.outputPath,
  });
}

Future<void> _generatePdfInIsolate(_PdfGenerationParams params) async {
  final pdf = pw.Document();

  for (final imagePath in params.imagePaths) {
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) continue;

    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    PdfPageFormat pageFormat;
    switch (params.config.pageFormat) {
      case PdfPageFormatOption.a4:
        pageFormat = PdfPageFormat.a4;
        break;
      case PdfPageFormatOption.letter:
        pageFormat = PdfPageFormat.letter;
        break;
      case PdfPageFormatOption.original:
        pageFormat = PdfPageFormat(
          image.width!.toDouble(),
          image.height!.toDouble(),
          marginAll: 0,
        );
        break;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );
  }

  final file = File(params.outputPath);
  await file.writeAsBytes(await pdf.save());
}
