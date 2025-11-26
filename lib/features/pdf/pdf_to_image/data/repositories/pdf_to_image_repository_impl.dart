import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/datasources/poppler_service.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/conversion_progress.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';

@LazySingleton(as: PdfToImageRepository)
class PdfToImageRepositoryImpl implements PdfToImageRepository {
  final PopplerService _popplerService;

  PdfToImageRepositoryImpl(this._popplerService);

  @override
  Stream<PdfToImageEvent> convert(PdfToImageParams params) async* {
    int totalPages = await _popplerService.getPageCount(params.inputFile);
    if (totalPages == 0) totalPages = 1;

    final stream = await _popplerService.convertPdfToImages(params);

    await for (final event in stream) {
      if (event['type'] == 'progress') {
        final int page = event['page'] as int;

        double percentage = 0.0;
        if (totalPages > 0) {
          percentage = (page / totalPages).clamp(0.0, 1.0);
        }
        yield PdfToImageProgress(
          ConversionProgress(
            currentPage: page,
            totalPages: totalPages,
            percentage: percentage,
          ),
        );
      } else if (event['type'] == 'done') {
        final List<String> paths = (event['files'] as List).cast<String>();
        final files = paths.map((p) => File(p)).toList();
        yield PdfToImageCompleted(files);
      } else if (event['type'] == 'error') {
        throw Exception(event['message']);
      }
    }
  }

  @override
  Future<void> saveImages(List<File> images, String destinationPath) async {
    for (final file in images) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      await file.copy('$destinationPath${Platform.pathSeparator}$fileName');
    }
  }
}
