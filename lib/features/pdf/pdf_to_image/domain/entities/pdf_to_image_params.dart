import 'package:equatable/equatable.dart';

class PdfToImageParams extends Equatable {
  final String jobId;
  final List<String> inputPaths;
  final String outputFormat;
  final int dpi;
  PdfToImageParams({
    required this.jobId,
    required List<String> inputPaths,
    this.outputFormat = 'jpg',
    this.dpi = 150,
  }) : inputPaths = List.unmodifiable(inputPaths);
  @override
  List<Object?> get props => [jobId, inputPaths, outputFormat, dpi];
}
