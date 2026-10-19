import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/pdf_conversion_failure.dart';

class PdfiumRuntime {
  final String executable;
  final List<String> arguments;
  final String libraryPath;
  const PdfiumRuntime({
    required this.executable,
    required this.arguments,
    required this.libraryPath,
  });
}

@lazySingleton
class PdfiumRuntimeLocator {
  Future<PdfiumRuntime>? _resolved;
  Future<PdfiumRuntime> resolve() async {
    ensureSupportedOperatingSystem(
      Platform.operatingSystem,
      Platform.operatingSystemVersion,
    );
    try {
      return await (_resolved ??= resolveAt(
        Platform.resolvedExecutable,
        Platform.operatingSystem,
        Abi.current().toString().contains('arm64') ? 'arm64' : 'x64',
        developmentRoot: const bool.fromEnvironment('dart.vm.product')
            ? null
            : Directory.current.path,
      ));
    } catch (_) {
      _resolved = null;
      throw const PdfConversionFailure(
        PdfConversionFailureCode.engineUnavailable,
      );
    }
  }

  static void ensureSupportedOperatingSystem(
    String operatingSystem,
    String operatingSystemVersion,
  ) {
    if (operatingSystem != 'macos') return;
    final major = int.tryParse(
      RegExp(r'Version (\d+)').firstMatch(operatingSystemVersion)?.group(1) ??
          '',
    );
    if (major != null && major < 13) {
      throw const PdfConversionFailure(
        PdfConversionFailureCode.unsupportedPlatform,
      );
    }
  }

  static Future<PdfiumRuntime> resolveAt(
    String executablePath,
    String operatingSystem,
    String architecture, {
    String? developmentRoot,
  }) async {
    if (!['windows', 'macos', 'linux'].contains(operatingSystem) ||
        !['x64', 'arm64'].contains(architecture)) {
      throw const PdfConversionFailure(
        PdfConversionFailureCode.engineUnavailable,
      );
    }
    final executableDirectory = path.dirname(executablePath);
    final runtimeDirectory = operatingSystem == 'macos'
        ? path.normalize(
            path.join(executableDirectory, '../Frameworks/PixiDeskPDFium'),
          )
        : path.join(executableDirectory, 'pdfium');
    final workerName = operatingSystem == 'windows'
        ? 'pixidesk_pdf_worker.exe'
        : 'pixidesk_pdf_worker';
    final workerPath = operatingSystem == 'macos'
        ? path.normalize(
            path.join(
              executableDirectory,
              '../Helpers',
              'pixidesk_pdf_worker_$architecture',
            ),
          )
        : path.join(runtimeDirectory, workerName);
    if (await File(workerPath).exists()) {
      final libraryPath = await _verifiedLibrary(runtimeDirectory);
      return PdfiumRuntime(
        executable: workerPath,
        arguments: const [],
        libraryPath: libraryPath,
      );
    }
    // Source-only development fallback; release packages always require their
    // bundled AOT helper and never depend on a system Dart SDK or network.
    if (developmentRoot != null &&
        await File(
          path.join(developmentRoot, 'tool/pdfium_worker.dart'),
        ).exists()) {
      final target = operatingSystem == 'macos'
          ? 'macos'
          : '$operatingSystem-$architecture';
      final libraryPath = await _verifiedLibrary(
        path.join(developmentRoot, 'native/pdfium/runtime', target),
      );
      final dartName = operatingSystem == 'windows' ? 'dart.exe' : 'dart';
      for (final directory in (Platform.environment['PATH'] ?? '').split(
        Platform.isWindows ? ';' : ':',
      )) {
        if (directory.isEmpty) continue;
        final candidate = File(path.join(directory, dartName));
        if (await candidate.exists()) {
          return PdfiumRuntime(
            executable: await candidate.resolveSymbolicLinks(),
            arguments: [path.join(developmentRoot, 'tool/pdfium_worker.dart')],
            libraryPath: libraryPath,
          );
        }
      }
    }
    throw const PdfConversionFailure(
      PdfConversionFailureCode.engineUnavailable,
    );
  }

  static Future<String> _verifiedLibrary(String directory) async {
    final manifest =
        jsonDecode(
              await File(path.join(directory, 'runtime.json')).readAsString(),
            )
            as Map<String, dynamic>;
    if (manifest['revision'] != 'chromium/8100') {
      throw const FormatException('Unsupported PDFium revision');
    }
    final libraryPath = path.normalize(
      path.join(directory, manifest['library'] as String),
    );
    if (!path.isWithin(path.normalize(directory), libraryPath)) {
      throw const FormatException('Unsafe library path');
    }
    final digest = await sha256.bind(File(libraryPath).openRead()).first;
    if (digest.toString() != manifest['librarySha256']) {
      throw const FormatException('PDFium checksum mismatch');
    }
    return libraryPath;
  }
}
