import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pdf_config.dart';
import '../../domain/entities/pdf_image_item.dart';

enum PdfConverterStatus { initial, loading, success, error }

class PdfConverterState extends Equatable {
  final List<PdfImageItem> images;
  final PdfConfig config;
  final bool isGridView;
  final PdfConverterStatus status;
  final File? generatedPdf;
  final String? errorMessage;

  const PdfConverterState({
    this.images = const [],
    this.config = const PdfConfig(),
    this.isGridView = true,
    this.status = PdfConverterStatus.initial,
    this.generatedPdf,
    this.errorMessage,
  });

  PdfConverterState copyWith({
    List<PdfImageItem>? images,
    PdfConfig? config,
    bool? isGridView,
    PdfConverterStatus? status,
    File? generatedPdf,
    String? errorMessage,
  }) {
    return PdfConverterState(
      images: images ?? this.images,
      config: config ?? this.config,
      isGridView: isGridView ?? this.isGridView,
      status: status ?? this.status,
      generatedPdf: generatedPdf ?? this.generatedPdf,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    images,
    config,
    isGridView,
    status,
    generatedPdf,
    errorMessage,
  ];
}
