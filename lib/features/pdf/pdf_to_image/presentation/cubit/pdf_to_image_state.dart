import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/conversion_progress.dart';

enum PdfToImageStatus {
  initial,
  converting,
  review,
  saving,
  savedSuccess,
  error,
}

class PdfToImageState extends Equatable {
  final PdfToImageStatus status;
  final File? selectedFile;
  final String outputFormat;
  final int dpi;
  final ConversionProgress? progress;
  final List<File>? generatedImages;
  final String? errorMessage;
  final String? successMessage;
  final Set<String> selectedImagePaths;
  final Map<String, int> imageRotations;

  const PdfToImageState({
    this.status = PdfToImageStatus.initial,
    this.selectedFile,
    this.outputFormat = 'jpg',
    this.dpi = 150,
    this.progress,
    this.generatedImages,
    this.errorMessage,
    this.successMessage,
    this.selectedImagePaths = const {},
    this.imageRotations = const {},
  });

  PdfToImageState copyWith({
    PdfToImageStatus? status,
    File? selectedFile,
    String? outputFormat,
    int? dpi,
    ConversionProgress? progress,
    List<File>? generatedImages,
    String? errorMessage,
    String? successMessage,
    Set<String>? selectedImagePaths,
    Map<String, int>? imageRotations,
  }) {
    return PdfToImageState(
      status: status ?? this.status,
      selectedFile: selectedFile ?? this.selectedFile,
      outputFormat: outputFormat ?? this.outputFormat,
      dpi: dpi ?? this.dpi,
      progress: progress ?? this.progress,
      generatedImages: generatedImages ?? this.generatedImages,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
      imageRotations: imageRotations ?? this.imageRotations,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedFile,
    outputFormat,
    dpi,
    progress,
    generatedImages,
    errorMessage,
    successMessage,
    selectedImagePaths,
    imageRotations,
  ];
}
