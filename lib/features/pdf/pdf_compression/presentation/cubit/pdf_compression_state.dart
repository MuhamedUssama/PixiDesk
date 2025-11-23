import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';

import 'dart:typed_data';

enum PdfCompressionStatus { initial, loading, success, error }

class PdfCompressionState extends Equatable {
  final PdfCompressionStatus status;
  final File? selectedFile;
  final File? compressedFile;
  final CompressionLevel compressionLevel;
  final String? errorMessage;
  final Uint8List? previewBytes;
  final PdfCompressionStatus previewStatus;

  const PdfCompressionState({
    this.status = PdfCompressionStatus.initial,
    this.selectedFile,
    this.compressedFile,
    this.compressionLevel = CompressionLevel.ebook,
    this.errorMessage,
    this.previewBytes,
    this.previewStatus = PdfCompressionStatus.initial,
  });

  PdfCompressionState copyWith({
    PdfCompressionStatus? status,
    File? selectedFile,
    File? compressedFile,
    CompressionLevel? compressionLevel,
    String? errorMessage,
    Uint8List? previewBytes,
    PdfCompressionStatus? previewStatus,
  }) {
    return PdfCompressionState(
      status: status ?? this.status,
      selectedFile: selectedFile ?? this.selectedFile,
      compressedFile: compressedFile ?? this.compressedFile,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      errorMessage: errorMessage,
      previewBytes: previewBytes ?? this.previewBytes,
      previewStatus: previewStatus ?? this.previewStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedFile,
    compressedFile,
    compressionLevel,
    errorMessage,
    previewBytes,
    previewStatus,
  ];
}
