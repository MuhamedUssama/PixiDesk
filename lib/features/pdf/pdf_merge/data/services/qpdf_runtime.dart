import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/pdf_merge_failure.dart';

@lazySingleton
class QpdfRuntimeLocator {
  Future<String>? _resolved;
  Future<String> resolve() async {
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
      throw const PdfMergeFailure(PdfMergeFailureCode.engineUnavailable);
    }
  }

  static Future<String> resolveAt(
    String executable,
    String operatingSystem,
    String architecture, {
    String? developmentRoot,
  }) async {
    if (!['macos', 'windows', 'linux'].contains(operatingSystem) ||
        !['arm64', 'x64'].contains(architecture)) {
      throw const FormatException('Unsupported target');
    }
    final target = '$operatingSystem-$architecture';
    final bundled = operatingSystem == 'macos'
        ? path.normalize(
            path.join(
              path.dirname(executable),
              '../Helpers/PixiDeskQPDF',
              architecture,
            ),
          )
        : path.join(path.dirname(executable), 'qpdf');
    final directory = await File(path.join(bundled, 'runtime.json')).exists()
        ? bundled
        : developmentRoot == null
        ? bundled
        : path.join(developmentRoot, 'native/qpdf/runtime', target);
    final manifest =
        jsonDecode(
              await File(path.join(directory, 'runtime.json')).readAsString(),
            )
            as Map<String, dynamic>;
    if (manifest['version'] != '12.4.2' || manifest['target'] != target) {
      throw const FormatException('Runtime mismatch');
    }
    final files = (manifest['files'] as Map).cast<String, String>();
    final executableName = manifest['executable'] as String;
    if (files.isEmpty || !files.containsKey(executableName)) {
      throw const FormatException('Missing executable digest');
    }
    for (final entry in files.entries) {
      final candidate = path.normalize(path.join(directory, entry.key));
      if (!path.isWithin(path.normalize(directory), candidate) ||
          !path.isWithin(
            await Directory(directory).resolveSymbolicLinks(),
            await File(candidate).resolveSymbolicLinks(),
          )) {
        throw const FormatException('Unsafe runtime path');
      }
      if ((await sha256.bind(File(candidate).openRead()).first).toString() !=
          entry.value) {
        throw const FormatException('Runtime checksum mismatch');
      }
    }
    return path.join(directory, executableName);
  }
}
