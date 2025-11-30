import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
    final binaryPath = getPopplerBinaryPath('pdftoppm');

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
      final binaryPath = getPopplerBinaryPath('pdfinfo');

      if (!File(binaryPath).existsSync()) {
        debugPrint('pdfinfo not found at $binaryPath');
        return 1;
      }

      log('PopplerService: Running pdfinfo for ${file.path}...');
      final result = await Process.run(
        binaryPath,
        [file.path],
        runInShell: false,
      ).timeout(const Duration(seconds: 10)); // Add timeout to prevent hang
      log(
        'PopplerService: pdfinfo finished for ${file.path}. Exit code: ${result.exitCode}',
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.startsWith('Pages:')) {
            final parts = line.split(':');
            if (parts.length > 1) {
              final count = int.tryParse(parts[1].trim());
              if (count != null) return count;
            }
          }
        }
      } else {
        log('PopplerService: pdfinfo failed. Stderr: ${result.stderr}');
      }
    } catch (e) {
      log('PopplerService: Error getting page count: $e');
      debugPrint('Error getting page count: $e');
    }

    return 1; // Default to 1 page if we can't determine
  }

  String getPopplerBinaryPath(String binaryName) {
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
  Process? process;

  // Cleanup old temporary directories
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
    final allGeneratedFiles = <String>[];
    final groupedFiles = <String, List<String>>{};

    for (int i = 0; i < params.inputFiles.length; i++) {
      final inputFile = params.inputFiles[i];

      // Create a temporary directory for output for THIS file
      final tempDir = await Directory.systemTemp.createTemp(
        'pdf_to_image_${i}_',
      );
      final outputPrefix = path.join(tempDir.path, 'page');

      // Determine format flag
      String formatFlag = '-jpeg'; // Default
      if (params.outputFormat.toLowerCase() == 'png') formatFlag = '-png';
      if (params.outputFormat.toLowerCase() == 'tiff') formatFlag = '-tiff';

      final args = [
        formatFlag,
        '-r', params.dpi.toString(),
        '-progress', // Report progress
        inputFile.path,
        outputPrefix,
      ];

      process = await Process.start(binaryPath, args, runInShell: false);

      // Actively drain stdout
      process.stdout.drain();

      // Listen to stderr for progress
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
                  sendPort.send({
                    'type': 'progress',
                    'fileIndex': i,
                    'page': pageNum,
                  });
                }
              }
            }
          });

      // File System Polling for Progress
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
            sendPort.send({
              'type': 'progress',
              'fileIndex': i,
              'page': lastFileCount,
            });
          }
        } catch (e) {
          // Ignore errors
        }
      });

      final exitCode = await process.exitCode;
      flushTimer.cancel();
      await stderrSubscription.cancel();

      if (exitCode == 0) {
        // Small delay to ensure OS flushes all files
        await Future.delayed(const Duration(milliseconds: 200));

        final files = tempDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.contains('page') && _isImage(f.path))
            .toList();

        files.sort((a, b) => a.path.compareTo(b.path));

        // Final progress check
        if (files.length > lastFileCount) {
          sendPort.send({
            'type': 'progress',
            'fileIndex': i,
            'page': files.length,
          });
        }

        final filePaths = files.map((f) => f.path).toList();
        allGeneratedFiles.addAll(filePaths);
        groupedFiles[inputFile.path] = filePaths;
      } else {
        sendPort.send({
          'type': 'error',
          'message':
              'Process exited with code $exitCode for file ${inputFile.path}',
        });
        return; // Stop processing on error
      }
    }

    sendPort.send({
      'type': 'done',
      'files': allGeneratedFiles,
      'groupedFiles': groupedFiles,
    });
  } catch (e, stackTrace) {
    flushTimer?.cancel();
    sendPort.send({
      'type': 'error',
      'message': e.toString(),
      'stack': stackTrace.toString(),
    });
  } finally {
    flushTimer?.cancel();
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

class ParallelIsolateParams {
  final SendPort sendPort;
  final String taskId;
  final String inputFilePath;
  final String outputFormat;
  final int dpi;
  final int startPage;
  final int endPage;
  final String binaryPath;

  ParallelIsolateParams({
    required this.sendPort,
    required this.taskId,
    required this.inputFilePath,
    required this.outputFormat,
    required this.dpi,
    required this.startPage,
    required this.endPage,
    required this.binaryPath,
  });
}

Future<void> parallelIsolateEntryPoint(ParallelIsolateParams params) async {
  final sendPort = params.sendPort;
  final binaryPath = params.binaryPath;

  sendPort.send({
    'type': 'log',
    'message': 'Isolate started for task ${params.taskId}. Binary: $binaryPath',
  });

  Timer? flushTimer;
  Process? process;
  Directory? tempDir;

  try {
    // Create a temporary directory for output for THIS task
    tempDir = await Directory.systemTemp.createTemp(
      'pdf_task_${params.taskId}_',
    );
    final outputPrefix = path.join(tempDir.path, 'page');

    // Determine format flag
    String formatFlag = '-jpeg'; // Default
    if (params.outputFormat.toLowerCase() == 'png') formatFlag = '-png';
    if (params.outputFormat.toLowerCase() == 'tiff') formatFlag = '-tiff';

    final args = [
      formatFlag,
      '-r', params.dpi.toString(),
      '-f', params.startPage.toString(),
      '-l', params.endPage.toString(),
      '-progress', // Report progress
      params.inputFilePath,
      outputPrefix,
    ];

    process = await Process.start(binaryPath, args, runInShell: false);

    // Actively drain stdout
    process.stdout.drain();

    // Listen to stderr for progress
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
                // Send relative page count
                final relativePage = pageNum - params.startPage + 1;
                sendPort.send({
                  'type': 'progress',
                  'taskId': params.taskId,
                  'page': relativePage,
                });
              }
            }
          }
        });

    // File System Polling for Progress
    int lastFileCount = 0;
    flushTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      try {
        final files = tempDir!
            .listSync()
            .whereType<File>()
            .where((f) => f.path.contains('page') && _isImage(f.path))
            .toList();

        if (files.length > lastFileCount) {
          lastFileCount = files.length;
          sendPort.send({
            'type': 'progress',
            'taskId': params.taskId,
            'page': lastFileCount,
          });
        }
      } catch (e) {
        // Ignore errors
      }
    });

    final exitCode = await process.exitCode;
    flushTimer.cancel();
    await stderrSubscription.cancel();

    if (exitCode == 0) {
      // Small delay to ensure OS flushes all files
      await Future.delayed(const Duration(milliseconds: 200));

      final files = tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('page') && _isImage(f.path))
          .toList();

      files.sort((a, b) => a.path.compareTo(b.path));

      final filePaths = files.map((f) => f.path).toList();

      sendPort.send({
        'type': 'done',
        'taskId': params.taskId,
        'files': filePaths,
        'sourcePath': params.inputFilePath,
      });
    } else {
      sendPort.send({
        'type': 'error',
        'taskId': params.taskId,
        'message':
            'Process exited with code $exitCode for task ${params.taskId}',
      });
    }
  } catch (e, stackTrace) {
    flushTimer?.cancel();
    sendPort.send({
      'type': 'error',
      'taskId': params.taskId,
      'message': e.toString(),
      'stack': stackTrace.toString(),
    });
  } finally {
    flushTimer?.cancel();
    process?.kill(ProcessSignal.sigkill);
    Isolate.exit();
  }
}
