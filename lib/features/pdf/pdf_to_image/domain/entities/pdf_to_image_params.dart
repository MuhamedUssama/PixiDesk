import 'dart:io';
import 'package:equatable/equatable.dart';

class PdfToImageParams extends Equatable {
  final File inputFile;
  final String outputFormat;
  final int dpi;

  const PdfToImageParams({
    required this.inputFile,
    required this.outputFormat,
    required this.dpi,
  });

  @override
  List<Object?> get props => [inputFile, outputFormat, dpi];
}
