import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/repositories/pdf_compression_repository.dart';

import 'dart:typed_data';

@injectable
class CompressPdfUseCase {
  final PdfCompressionRepository _repository;

  CompressPdfUseCase(this._repository);

  Future<File> call({
    required File input,
    required CompressionLevel level,
  }) async {
    return _repository.compressPdf(input: input, level: level);
  }

  Future<Uint8List> getPdfBytes(File file) async {
    return _repository.getPdfBytes(file);
  }
}
