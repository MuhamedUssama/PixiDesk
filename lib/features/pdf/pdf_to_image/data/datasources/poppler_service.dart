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
    final binaryPath = _getPopplerBinaryPath('pdftoppm');

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
      final binaryPath = _getPopplerBinaryPath('pdfinfo');

      if (!File(binaryPath).existsSync()) {
        debugPrint('pdfinfo not found at $binaryPath');
        return 0;
      }

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

  String _getPopplerBinaryPath(String binaryName) {
    final executableDir = path.dirname(Platform.resolvedExecutable);

    if (Platform.isWindows) {
      return path.join(executableDir, 'poppler', '$binaryName.exe');
    } else if (Platform.isMacOS) {
      return path.join(executableDir, 'poppler', binaryName);
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

  Timer? flushTimer;
  Process? process; // FIX 1: Define process in outer scope

  // FIX 2: Cleanup old temporary directories
  try {
    final systemTemp = Directory.systemTemp;
    if (systemTemp.existsSync()) {
      final entities = systemTemp.listSync();
      for (final entity in entities) {
        if (entity is Directory &&
            path.basename(entity.path).startsWith('pdf_to_image_')) {
          try {
            entity.deleteSync(recursive: true);
          } catch (e) {
            // Ignore errors (e.g. locked files)
          }
        }
      }
    }
  } catch (e) {
    // Ignore cleanup errors
  }

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

    process = await Process.start(binaryPath, args, runInShell: false);

    // CRITICAL FIX 1: Actively drain stdout to prevent OS buffering issues on Windows.
    // We don't need the data, but we must keep the pipe flowing.
    process.stdout.drain();

    // CRITICAL FIX 2: Use an active listen subscription for stderr progress.
    StreamSubscription<String>? stderrSubscription;
    stderrSubscription = process.stderr
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

    // CRITICAL FIX 3: File System Polling for Progress
    // Instead of relying on stderr (which buffers) or stdin hacking (which deadlocks),
    // we poll the output directory for generated files. This is robust and fast.
    int lastFileCount = 0;
    flushTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      try {
        final files = tempDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.contains('page') && _isImage(f.path))
            .toList();

        if (files.length > lastFileCount) {
          lastFileCount = files.length;
          // Send progress for the latest page count
          sendPort.send({'type': 'progress', 'page': lastFileCount});
        }
      } catch (e) {
        // Ignore errors during polling (e.g. file lock contention)
      }
    });

    // 3. Wait for the process to finish naturally.
    final exitCode = await process.exitCode;

    // Stop the flushing timer immediately.
    flushTimer.cancel();

    // 4. Ensure we finish processing any remaining logs and clean up.
    await stderrSubscription.cancel();

    if (exitCode == 0) {
      // Small delay to ensure OS flushes all files to disk listing
      await Future.delayed(const Duration(milliseconds: 200));

      // List generated files
      final files = tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('page') && _isImage(f.path))
          .toList();

      // Sort by name to ensure order
      files.sort((a, b) => a.path.compareTo(b.path));

      // CRITICAL FIX 4: Final Progress Check (Refined)
      // Ensure we send the 100% progress event if we haven't yet.
      // This guarantees the UI transitions gracefully.
      if (files.length > lastFileCount) {
        sendPort.send({'type': 'progress', 'page': files.length});
      }

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
    flushTimer?.cancel();
    sendPort.send({
      'type': 'error',
      'message': e.toString(),
      'stack': stackTrace.toString(),
    });
  } finally {
    flushTimer?.cancel();
    // FIX 1: Ensure process is killed to prevent zombies
    process?.kill(ProcessSignal.sigkill);
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
