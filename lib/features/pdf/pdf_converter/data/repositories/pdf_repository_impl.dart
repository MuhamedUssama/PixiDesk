import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
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
        rotations: images.map((e) => e.quarterTurns).toList(),
        config: config,
        outputPath: outputPath,
      ),
    );

    return File(outputPath);
  }
}

class _PdfGenerationParams {
  final List<String> imagePaths;
  final List<int> rotations;
  final PdfConfig config;
  final String outputPath;

  _PdfGenerationParams({
    required this.imagePaths,
    required this.rotations,
    required this.config,
    required this.outputPath,
  });
}

Future<void> _generatePdfInIsolate(_PdfGenerationParams params) async {
  final pdf = pw.Document();

  for (var i = 0; i < params.imagePaths.length; i++) {
    final imagePath = params.imagePaths[i];
    final rotation = params.rotations[i];
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) continue;

    Uint8List imageBytes = await imageFile.readAsBytes();

    if (rotation > 0) {
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage != null) {
        final rotatedImage = img.copyRotate(decodedImage, angle: rotation * 90);
        imageBytes = Uint8List.fromList(img.encodeJpg(rotatedImage));
      }
    }

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
