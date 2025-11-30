import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:archive/archive_io.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
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
    int totalPages = 0;
    for (final file in params.inputFiles) {
      totalPages += await _popplerService.getPageCount(file);
    }
    if (totalPages == 0) totalPages = 1;

    final stream = await _popplerService.convertPdfToImages(params);
    final Map<int, int> pagesProcessedPerFile = {};

    await for (final event in stream) {
      if (event['type'] == 'progress') {
        final int page = event['page'] as int;
        final int fileIndex = event['fileIndex'] as int;

        pagesProcessedPerFile[fileIndex] = page;
        final int totalProcessed = pagesProcessedPerFile.values.fold(
          0,
          (a, b) => a + b,
        );

        double percentage = 0.0;
        if (totalPages > 0) {
          percentage = (totalProcessed / totalPages).clamp(0.0, 1.0);
        }
        yield PdfToImageProgress(
          ConversionProgress(
            currentPage: totalProcessed,
            totalPages: totalPages,
            percentage: percentage,
          ),
        );
      } else if (event['type'] == 'done') {
        final List<String> paths = (event['files'] as List).cast<String>();
        final Map<String, dynamic> groupedPathsRaw =
            event['groupedFiles'] as Map<String, dynamic>;
        final Map<String, List<String>> groupedPaths = groupedPathsRaw.map(
          (key, value) => MapEntry(key, (value as List).cast<String>()),
        );

        final files = paths.map((p) => File(p)).toList();
        final groupedFiles = groupedPaths.map(
          (k, v) => MapEntry(k, v.map((p) => File(p)).toList()),
        );

        yield PdfToImageCompleted(files, groupedImages: groupedFiles);
      } else if (event['type'] == 'error') {
        throw Exception(event['message']);
      }
    }
  }

  @override
  Future<void> saveImages(
    List<File> images,
    String destinationDirectory, {
    Map<String, int>? rotations,
  }) async {
    for (final file in images) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final destinationFile = File(
        '$destinationDirectory${Platform.pathSeparator}$fileName',
      );
      final rotation = rotations?[file.path] ?? 0;

      if (rotation == 0) {
        // Path A: No rotation, simple copy
        await file.copy(destinationFile.path);
      } else {
        await _saveRotatedImage(file, destinationFile.path, rotation);
      }
    }
  }

  @override
  Future<void> saveAsZip(
    List<File> images,
    String destinationPath, {
    Map<String, int>? rotations,
  }) async {
    final encoder = ZipFileEncoder();
    encoder.create(destinationPath);

    try {
      await _addImagesToZip(encoder, images, rotations);
    } finally {
      encoder.close();
    }
  }

  @override
  Future<void> saveAsSeparateZips(
    Map<String, List<File>> groupedImages,
    String destinationDirectory, {
    Map<String, int>? rotations,
  }) async {
    for (final entry in groupedImages.entries) {
      final sourceFilePath = entry.key;
      final images = entry.value;

      final sourceFileName = sourceFilePath.split(Platform.pathSeparator).last;
      final zipFileName = '${path.withoutExtension(sourceFileName)}.zip';
      final zipFilePath = path.join(destinationDirectory, zipFileName);

      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);

      try {
        await _addImagesToZip(encoder, images, rotations);
      } finally {
        encoder.close();
      }
    }
  }

  Future<void> _addImagesToZip(
    ZipFileEncoder encoder,
    List<File> images,
    Map<String, int>? rotations,
  ) async {
    for (final file in images) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final rotation = rotations?[file.path] ?? 0;

      if (rotation == 0) {
        await encoder.addFile(file, fileName);
      } else {
        // For rotated images, we need to process them first
        // We'll create a temporary file for the rotated version
        final tempDir = await Directory.systemTemp.createTemp('rotated_');
        final tempFile = File(
          '${tempDir.path}${Platform.pathSeparator}$fileName',
        );

        try {
          await _saveRotatedImage(file, tempFile.path, rotation);
          await encoder.addFile(tempFile, fileName);
        } finally {
          // Cleanup temp file immediately after adding to zip
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
          if (await tempDir.exists()) {
            await tempDir.delete();
          }
        }
      }
    }
  }

  Future<void> _saveRotatedImage(
    File sourceFile,
    String destinationPath,
    int rotation,
  ) async {
    try {
      final params = ImageProcessingParams(
        sourcePath: sourceFile.path,
        destinationPath: destinationPath,
        rotation: rotation,
      );

      await compute(processImageInIsolate, params);
    } catch (e) {
      throw Exception('Failed to process image: ${sourceFile.path}. Error: $e');
    }
  }
}

class ImageProcessingParams {
  final String sourcePath;
  final String destinationPath;
  final int rotation;

  ImageProcessingParams({
    required this.sourcePath,
    required this.destinationPath,
    required this.rotation,
  });
}

Future<void> processImageInIsolate(ImageProcessingParams params) async {
  final sourceFile = File(params.sourcePath);
  final bytes = await sourceFile.readAsBytes();
  final image = img.decodeImage(bytes);

  if (image != null) {
    // Rotate the image (90 degrees * quarterTurns)
    final rotatedImage = img.copyRotate(image, angle: params.rotation * 90);

    // Encode back to original format
    final fileName = params.sourcePath.split(Platform.pathSeparator).last;
    final extension = fileName.split('.').last.toLowerCase();
    List<int> encodedBytes;

    if (extension == 'png') {
      encodedBytes = img.encodePng(rotatedImage);
    } else {
      // Default to JPG with quality 95
      encodedBytes = img.encodeJpg(rotatedImage, quality: 95);
    }

    final destFile = File(params.destinationPath);
    await destFile.writeAsBytes(encodedBytes);
  } else {
    throw Exception('Failed to decode image');
  }
}
