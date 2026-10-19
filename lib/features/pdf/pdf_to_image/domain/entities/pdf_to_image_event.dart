import 'package:equatable/equatable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/conversion_progress.dart';

abstract class PdfToImageEvent extends Equatable {
  const PdfToImageEvent();

  @override
  List<Object?> get props => [];
}

class PdfToImageProgress extends PdfToImageEvent {
  final ConversionProgress progress;

  const PdfToImageProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class PdfToImageCompleted extends PdfToImageEvent {
  final List<String> imagePaths;
  final Map<String, List<String>> groupedPaths;

  final Map<String, String> previewPaths;
  final Map<String, String> thumbnailPaths;
  const PdfToImageCompleted(
    this.imagePaths, {
    this.groupedPaths = const {},
    this.previewPaths = const {},
    this.thumbnailPaths = const {},
  });

  @override
  List<Object?> get props => [
    imagePaths,
    groupedPaths,
    previewPaths,
    thumbnailPaths,
  ];
}
