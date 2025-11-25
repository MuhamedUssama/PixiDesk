import 'dart:io';
import 'dart:typed_data';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';

abstract class PdfCompressionRepository {
  Future<File> compressPdf({
    required File input,
    required CompressionLevel level,
  });

  Future<Uint8List> getPdfBytes(File file);
}
