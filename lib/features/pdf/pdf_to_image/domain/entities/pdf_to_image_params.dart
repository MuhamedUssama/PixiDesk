import 'dart:io';
import 'package:equatable/equatable.dart';

class PdfToImageParams extends Equatable {
  final List<File> inputFiles;
  final String outputFormat;
  final int dpi;

  const PdfToImageParams({
    required this.inputFiles,
    this.outputFormat = 'jpg',
    this.dpi = 200,
  });

  @override
  List<Object?> get props => [inputFiles, outputFormat, dpi];
}
