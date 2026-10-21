import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversion_progress.dart';
import '../../../shared/domain/entities/pdf_processing_failure.dart';
part 'pdf_to_image_state.freezed.dart';

enum PdfToImageStatus {
  initial,
  converting,
  cancelling,
  saving,
  review,
  savedSuccess,
  error,
}

enum PdfExportSuccess { images, archive, separateArchives }

@freezed
abstract class PdfToImageState with _$PdfToImageState {
  const PdfToImageState._();
  const factory PdfToImageState({
    @Default(PdfToImageStatus.initial) PdfToImageStatus status,
    @Default([]) List<File> selectedFiles,
    @Default('jpg') String outputFormat,
    @Default(150) int dpi,
    ConversionProgress? progress,
    List<File>? generatedImages,
    PdfProcessingFailureCode? failure,
    PdfExportSuccess? success,
    @Default(0) int messageId,
    @Default({}) Map<String, String> previewPaths,
    @Default({}) Map<String, String> thumbnailPaths,
    @Default({}) Set<String> selectedImagePaths,
    @Default({}) Map<String, int> imageRotations,
    @Default({}) Map<String, List<File>> groupedImages,
  }) = _PdfToImageState;

  bool get isBusy =>
      status == PdfToImageStatus.converting ||
      status == PdfToImageStatus.cancelling ||
      status == PdfToImageStatus.saving;
}
