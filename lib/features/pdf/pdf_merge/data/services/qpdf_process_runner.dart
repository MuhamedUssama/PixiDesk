import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/pdf_merge_failure.dart';
import 'qpdf_runtime.dart';

@injectable
class QpdfProcessRunner {
  final QpdfRuntimeLocator _runtime;
  final Set<Process> _processes = {};
  int _generation = 0;
  QpdfProcessRunner(this._runtime);

  Future<String> run(
    Map<String, Object?> job, {
    void Function(double)? onProgress,
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final generation = _generation;
    Directory? jobDirectory;
    Process? process;
    StreamSubscription<String>? outputSubscription;
    StreamSubscription<String>? errorSubscription;
    try {
      final executable = await _runtime.resolve();
      if (generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
      jobDirectory = await Directory.systemTemp.createTemp(
        'pixidesk_qpdf_job_',
      );
      final configuration = File(path.join(jobDirectory.path, 'request.json'));
      // Passwords never enter argv, logs, or presentation state. The private job
      // directory and configuration are removed after the process exits.
      await configuration.writeAsString(jsonEncode(job), flush: true);
      if (generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
      process = await Process.start(executable, [
        '--job-json-file=${configuration.path}',
      ], runInShell: false);
      _processes.add(process);
      final child = process;
      PdfMergeFailure? captureFailure;
      final output = StringBuffer();
      final errors = StringBuffer();
      final outputDone = Completer<void>();
      final errorsDone = Completer<void>();
      void capture(String line, StringBuffer destination, int limit) {
        if (destination.length + line.length > limit) {
          captureFailure = const PdfMergeFailure(
            PdfMergeFailureCode.resourceLimit,
          );
          child.kill(ProcessSignal.sigkill);
          return;
        }
        destination.writeln(line);
      }

      Stream<String> boundedLines(Stream<List<int>> bytes, int limit) {
        var byteCount = 0;
        return bytes
            .map((chunk) {
              byteCount += chunk.length;
              if (byteCount > limit) {
                captureFailure = const PdfMergeFailure(
                  PdfMergeFailureCode.resourceLimit,
                );
                child.kill(ProcessSignal.sigkill);
                throw captureFailure!;
              }
              return chunk;
            })
            .transform(utf8.decoder)
            .transform(const LineSplitter());
      }

      outputSubscription = boundedLines(child.stdout, 32 * 1024 * 1024).listen(
        (line) {
          capture(line, output, 32 * 1024 * 1024);
          final progress = RegExp(r'write progress: (\d+)%').firstMatch(line);
          if (progress != null) {
            onProgress?.call(int.parse(progress.group(1)!) / 100);
          }
        },
        onDone: () {
          if (!outputDone.isCompleted) outputDone.complete();
        },
        onError: (Object _) {
          captureFailure ??= const PdfMergeFailure(
            PdfMergeFailureCode.mergeFailed,
          );
          child.kill(ProcessSignal.sigkill);
          if (!outputDone.isCompleted) outputDone.complete();
        },
      );
      errorSubscription = boundedLines(child.stderr, 1024 * 1024).listen(
        (line) => capture(line, errors, 1024 * 1024),
        onDone: () {
          if (!errorsDone.isCompleted) errorsDone.complete();
        },
        onError: (Object _) {
          captureFailure ??= const PdfMergeFailure(
            PdfMergeFailureCode.mergeFailed,
          );
          child.kill(ProcessSignal.sigkill);
          if (!errorsDone.isCompleted) errorsDone.complete();
        },
      );
      if (generation != _generation) child.kill(ProcessSignal.sigkill);
      final exitCode = await child.exitCode.timeout(timeout);
      await Future.wait([
        outputDone.future,
        errorsDone.future,
      ]).timeout(const Duration(seconds: 5));
      if (generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
      if (captureFailure case final failure?) throw failure;
      if (exitCode != 0) {
        throw PdfMergeFailure(
          errors.toString().toLowerCase().contains('password')
              ? PdfMergeFailureCode.passwordRequired
              : PdfMergeFailureCode.invalidDocument,
        );
      }
      return output.toString();
    } on TimeoutException {
      throw const PdfMergeFailure(PdfMergeFailureCode.timedOut);
    } on PdfMergeFailure {
      rethrow;
    } on FileSystemException {
      throw const PdfMergeFailure(PdfMergeFailureCode.permissionDenied);
    } on ProcessException {
      throw const PdfMergeFailure(PdfMergeFailureCode.engineUnavailable);
    } catch (_) {
      throw const PdfMergeFailure(PdfMergeFailureCode.mergeFailed);
    } finally {
      if (process != null) {
        process.kill(ProcessSignal.sigkill);
        await process.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () => -1,
        );
        _processes.remove(process);
        await process.stdin
            .close()
            .timeout(const Duration(seconds: 5))
            .catchError((Object _) {});
      }
      await outputSubscription?.cancel();
      await errorSubscription?.cancel();
      try {
        if (jobDirectory != null && await jobDirectory.exists()) {
          await jobDirectory.delete(recursive: true);
        }
      } on FileSystemException {
        // Preserve the operation's typed failure if a temp volume disappears.
      }
    }
  }

  Future<void> cancel() async {
    _generation++;
    final active = _processes.toList();
    for (final process in active) {
      process.kill(ProcessSignal.sigkill);
    }
    await Future.wait(
      active.map(
        (process) => process.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () => -1,
        ),
      ),
    );
  }
}
