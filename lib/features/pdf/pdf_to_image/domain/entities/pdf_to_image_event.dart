import 'dart:io';
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
  final List<File> images;
  final Map<String, List<File>> groupedImages;

  const PdfToImageCompleted(this.images, {this.groupedImages = const {}});

  @override
  List<Object?> get props => [images, groupedImages];
}
