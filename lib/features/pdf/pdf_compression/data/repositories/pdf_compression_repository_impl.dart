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
    // We need to pass simple types to the isolate.
    // Services cannot be passed directly if they contain non-sendable objects.
    // However, GhostscriptCompressionService is stateless and only uses standard libraries.
    // But to be safe and follow best practices, we'll create the service inside the isolate
    // or pass the necessary data to a static function.

    // Since we are using DI, we can't easily inject into the static function.
    // We will pass the necessary paths and level string to the compute function.

    return compute(
      _compressInIsolate,
      _CompressionParams(
        inputPath: input.path,
        outputPath: outputPath,
        level: level,
      ),
    );
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
  // We instantiate the service manually here since we are in a new Isolate
  // and don't have access to the main GetIt instance.
  final service = GhostscriptCompressionService();
  return service.compressPdf(
    input: File(params.inputPath),
    outputPath: params.outputPath,
    level: params.level,
  );
}
