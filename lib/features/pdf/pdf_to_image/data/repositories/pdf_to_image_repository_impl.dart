import 'dart:isolate';
import 'package:injectable/injectable.dart';
import '../../domain/entities/pdf_to_image_event.dart';
import '../../domain/entities/pdf_to_image_params.dart';
import '../../domain/repositories/pdf_to_image_repository.dart';
import '../pdfium/pdfium_conversion_service.dart';
import '../pdfium/pdf_image_exporter.dart';

@LazySingleton(as: PdfToImageRepository)
class PdfToImageRepositoryImpl implements PdfToImageRepository {
  final PdfiumConversionService _conversionService;
  PdfToImageRepositoryImpl(this._conversionService);

  @override
  Stream<PdfToImageEvent> convert(PdfToImageParams params) =>
      _conversionService.convert(params);
  @override
  Future<void> cancelCurrentConversion(String jobId) =>
      _conversionService.cancel(jobId);
  @override
  Future<void> releaseConversion(String jobId) =>
      _conversionService.release(jobId);
  @override
  Future<void> saveImages(
    List<String> images,
    String destinationDirectory, {
    Map<String, int>? rotations,
  }) {
    final request = PdfFileExportRequest(
      mode: PdfFileExportMode.images,
      destination: destinationDirectory,
      images: images,
      rotations: rotations ?? const {},
    );
    return Isolate.run(() => exportPdfImages(request));
  }

  @override
  Future<void> saveAsZip(
    List<String> images,
    String destinationPath, {
    Map<String, int>? rotations,
  }) {
    final request = PdfFileExportRequest(
      mode: PdfFileExportMode.archive,
      destination: destinationPath,
      images: images,
      rotations: rotations ?? const {},
    );
    return Isolate.run(() => exportPdfImages(request));
  }

  @override
  Future<void> saveAsSeparateZips(
    Map<String, List<String>> groupedImages,
    String destinationDirectory, {
    Map<String, int>? rotations,
  }) {
    final request = PdfFileExportRequest(
      mode: PdfFileExportMode.separateArchives,
      destination: destinationDirectory,
      groupedImages: groupedImages,
      rotations: rotations ?? const {},
    );
    return Isolate.run(() => exportPdfImages(request));
  }
}
