import 'dart:io';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';

abstract class PdfToImageRepository {
  Stream<PdfToImageEvent> convert(PdfToImageParams params);
  Future<void> saveImages(
    List<File> images,
    String destinationDirectory, {
    Map<String, int>? rotations,
  });

  Future<void> saveAsZip(
    List<File> images,
    String destinationPath, {
    Map<String, int>? rotations,
  });

  Future<void> saveAsSeparateZips(
    Map<String, List<File>> groupedImages,
    String destinationDirectory, {
    Map<String, int>? rotations,
  });
}
