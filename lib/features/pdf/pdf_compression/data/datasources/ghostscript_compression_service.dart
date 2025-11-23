import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';

@injectable
class GhostscriptCompressionService {
  Future<File> compressPdf({
    required File input,
    required String outputPath,
    required CompressionLevel level,
  }) async {
    final executablePath = _getGhostscriptPath();

    if (!File(executablePath).existsSync()) {
      throw Exception('Ghostscript binary not found at: $executablePath');
    }

    final args = [
      '-sDEVICE=pdfwrite',
      '-dCompatibilityLevel=1.4',
      '-dPDFSETTINGS=${level.ghostscriptValue}',
      '-dNOPAUSE',
      '-dQUIET',
      '-dBATCH',
      '-sOutputFile=$outputPath',
      input.path,
    ];

    try {
      final result = await Process.run(executablePath, args);

      if (result.exitCode != 0) {
        throw Exception(
          'Ghostscript failed with exit code ${result.exitCode}: ${result.stderr}',
        );
      }

      final outputFile = File(outputPath);
      if (!outputFile.existsSync()) {
        throw Exception('Output file was not created.');
      }

      return outputFile;
    } catch (e) {
      throw Exception('Failed to execute Ghostscript: $e');
    }
  }

  String _getGhostscriptPath() {
    final executableDir = path.dirname(Platform.resolvedExecutable);

    if (Platform.isWindows) {
      return path.join(executableDir, 'gswin64c.exe');
    } else if (Platform.isMacOS) {
      return path.join(executableDir, 'gs');
    }

    throw UnsupportedError('Platform not supported for PDF compression');
  }
}
