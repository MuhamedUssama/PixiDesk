import 'dart:io';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';

abstract class PdfCompressionRepository {
  Future<File> compressPdf({
    required File input,
    required String outputPath,
    required CompressionLevel level,
  });
}
