import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';

enum PdfCompressionStatus { initial, loading, success, error }

class PdfCompressionState extends Equatable {
  final PdfCompressionStatus status;
  final File? selectedFile;
  final File? compressedFile;
  final CompressionLevel compressionLevel;
  final String? errorMessage;

  const PdfCompressionState({
    this.status = PdfCompressionStatus.initial,
    this.selectedFile,
    this.compressedFile,
    this.compressionLevel = CompressionLevel.ebook,
    this.errorMessage,
  });

  PdfCompressionState copyWith({
    PdfCompressionStatus? status,
    File? selectedFile,
    File? compressedFile,
    CompressionLevel? compressionLevel,
    String? errorMessage,
  }) {
    return PdfCompressionState(
      status: status ?? this.status,
      selectedFile: selectedFile ?? this.selectedFile,
      compressedFile: compressedFile ?? this.compressedFile,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedFile,
    compressedFile,
    compressionLevel,
    errorMessage,
  ];
}
