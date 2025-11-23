import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/data/datasources/ghostscript_compression_service.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/repositories/pdf_compression_repository.dart';

@LazySingleton(as: PdfCompressionRepository)
class PdfCompressionRepositoryImpl implements PdfCompressionRepository {
  PdfCompressionRepositoryImpl();

  @override
  Future<File> compressPdf({
    required File input,
    required String outputPath,
    required CompressionLevel level,
  }) async {
    return compute(
      _compressInIsolate,
      _CompressionParams(
        inputPath: input.path,
        outputPath: outputPath,
        level: level,
      ),
    );
  }

  @override
  Future<Uint8List> getPdfBytes(File file) async {
    return compute(_readBytesIsolate, file);
  }
}

class _CompressionParams {
  final String inputPath;
  final String outputPath;
  final CompressionLevel level;

  _CompressionParams({
    required this.inputPath,
    required this.outputPath,
    required this.level,
  });
}

Future<File> _compressInIsolate(_CompressionParams params) async {
  final service = GhostscriptCompressionService();
  return service.compressPdf(
    input: File(params.inputPath),
    outputPath: params.outputPath,
    level: params.level,
  );
}

Future<Uint8List> _readBytesIsolate(File file) async {
  return file.readAsBytes();
}
