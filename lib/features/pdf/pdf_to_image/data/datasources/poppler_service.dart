import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';

@injectable
class PopplerService {
  Future<Stream<dynamic>> convertPdfToImages(PdfToImageParams params) async {
    final receivePort = ReceivePort();

    // We need to pass the binary path to the isolate
    final binaryPath = await _getPopplerBinaryPath();

    await Isolate.spawn(
      _isolateEntryPoint,
      _IsolateParams(
        sendPort: receivePort.sendPort,
        params: params,
        binaryPath: binaryPath,
      ),
    );

    return receivePort.asBroadcastStream();
  }

  Future<int> getPageCount(File file) async {
    // Try to use pdfinfo if available
    try {
      final binaryPath = await _getPopplerBinaryPath(binaryName: 'pdfinfo');
      // If pdfinfo is not found, it might return 'pdfinfo' which might not be in PATH.
      // We can check if it exists or just try running it.

      final result = await Process.run(binaryPath, [file.path]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Look for "Pages: 123"
        final RegExp regExp = RegExp(r'Pages:\s+(\d+)');
        final match = regExp.firstMatch(output);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }
    } catch (e) {
      // Ignore errors, return 0
      debugPrint('Failed to get page count: $e');
    }
    return 0;
  }

  Future<String> _getPopplerBinaryPath({String binaryName = 'pdftoppm'}) async {
    String executable = binaryName;
    if (Platform.isWindows) {
      if (binaryName == 'pdftoppm') executable = 'pdftoppm.exe';
      if (binaryName == 'pdfinfo') executable = 'pdfinfo.exe';

      final exeDir = File(Platform.resolvedExecutable).parent;
      final localPath = path.join(
        exeDir.path,
        'data',
        'flutter_assets',
        'assets',
        'bin',
        'windows',
        executable,
      );

      if (await File(localPath).exists()) {
        return localPath;
      }
    } else if (Platform.isMacOS) {
      final exeDir = File(Platform.resolvedExecutable).parent;
      final localPath = path.join(
        exeDir.path,
        '..',
        'Frameworks',
        'App.framework',
        'Resources',
        'flutter_assets',
        'assets',
        'bin',
        'macos',
        binaryName,
      );
      if (await File(localPath).exists()) {
        return localPath;
      }
    }
    return binaryName;
  }
}

class _IsolateParams {
  final SendPort sendPort;
  final PdfToImageParams params;
  final String binaryPath;

  _IsolateParams({
    required this.sendPort,
    required this.params,
    required this.binaryPath,
  });
}

Future<void> _isolateEntryPoint(_IsolateParams isolateParams) async {
  final params = isolateParams.params;
  final sendPort = isolateParams.sendPort;
  final binaryPath = isolateParams.binaryPath;

  try {
    // Create a temporary directory for output
    final tempDir = await Directory.systemTemp.createTemp('pdf_to_image_');
    final outputPrefix = path.join(tempDir.path, 'page');

    // Determine format flag
    String formatFlag = '-jpeg'; // Default
    if (params.outputFormat.toLowerCase() == 'png') formatFlag = '-png';
    if (params.outputFormat.toLowerCase() == 'tiff') formatFlag = '-tiff';

    final args = [
      formatFlag,
      '-r', params.dpi.toString(),
      '-progress', // Report progress
      params.inputFile.path,
      outputPrefix,
    ];

    final process = await Process.start(binaryPath, args, runInShell: false);

    // Parse stderr for progress (pdftoppm writes progress to stderr)
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.trim().startsWith('Page ')) {
            final parts = line.trim().split(' ');
            if (parts.length >= 2) {
              final pageNum = int.tryParse(parts[1]);
              if (pageNum != null) {
                sendPort.send({'type': 'progress', 'page': pageNum});
              }
            }
          }
        });

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      // List generated files
      final files = tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('page') && _isImage(f.path))
          .toList();

      // Sort by name to ensure order
      files.sort((a, b) => a.path.compareTo(b.path));

      sendPort.send({
        'type': 'done',
        'files': files.map((f) => f.path).toList(),
      });
    } else {
      sendPort.send({
        'type': 'error',
        'message': 'Process exited with code $exitCode',
      });
    }
  } catch (e, stackTrace) {
    sendPort.send({
      'type': 'error',
      'message': e.toString(),
      'stack': stackTrace.toString(),
    });
  } finally {
    Isolate.exit();
  }
}

bool _isImage(String path) {
  final ext = path.toLowerCase();
  return ext.endsWith('.jpg') ||
      ext.endsWith('.jpeg') ||
      ext.endsWith('.png') ||
      ext.endsWith('.tif') ||
      ext.endsWith('.tiff');
}
