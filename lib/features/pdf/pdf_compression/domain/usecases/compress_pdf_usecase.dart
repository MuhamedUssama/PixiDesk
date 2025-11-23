import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/repositories/pdf_compression_repository.dart';

@injectable
class CompressPdfUseCase {
  final PdfCompressionRepository _repository;

  CompressPdfUseCase(this._repository);

  Future<File> call({
    required File input,
    required String outputPath,
    required CompressionLevel level,
  }) {
    return _repository.compressPdf(
      input: input,
      outputPath: outputPath,
      level: level,
    );
  }
}
