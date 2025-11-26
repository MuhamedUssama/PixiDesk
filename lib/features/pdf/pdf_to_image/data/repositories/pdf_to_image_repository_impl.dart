import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
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
  Future<void> saveImages(
    List<File> images,
    String destinationPath,
    Map<String, int> rotations,
  ) async {
    for (final file in images) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final destinationFile = File(
        '$destinationPath${Platform.pathSeparator}$fileName',
      );
      final rotation = rotations[file.path] ?? 0;

      if (rotation == 0) {
        // Path A: No rotation, simple copy
        await file.copy(destinationFile.path);
      } else {
        // Path B: Needs rotation
        try {
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);

          if (image != null) {
            // Rotate the image (90 degrees * quarterTurns)
            final rotatedImage = img.copyRotate(image, angle: rotation * 90);

            // Encode back to original format (assuming JPG for now based on typical usage,
            // but ideally we should check extension)
            final extension = fileName.split('.').last.toLowerCase();
            List<int> encodedBytes;

            if (extension == 'png') {
              encodedBytes = img.encodePng(rotatedImage);
            } else {
              // Default to JPG
              encodedBytes = img.encodeJpg(rotatedImage, quality: 100);
            }

            await destinationFile.writeAsBytes(encodedBytes);
          } else {
            // Fallback if decoding fails
            await file.copy(destinationFile.path);
          }
        } catch (e) {
          // Fallback on error
          await file.copy(destinationFile.path);
        }
      }
    }
  }
}
