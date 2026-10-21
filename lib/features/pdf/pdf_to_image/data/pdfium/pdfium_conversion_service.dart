import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/conversion_progress.dart';
import '../../domain/entities/pdf_conversion_failure.dart';
import '../../domain/entities/pdf_to_image_event.dart';
import '../../domain/entities/pdf_to_image_params.dart';
import 'pdfium_runtime.dart';
import 'pdfium_worker_client.dart';

@lazySingleton
class PdfiumConversionService {
  final PdfiumRuntimeLocator _runtimeLocator;
  final Map<String, _PdfConversionJob> _jobs = {};
  bool _running = false;
  final int _workerLimit;
  final Duration _jobTimeout;
  PdfiumConversionService(this._runtimeLocator)
    : _workerLimit = 8,
      _jobTimeout = const Duration(minutes: 30);
  PdfiumConversionService.testing(
    this._runtimeLocator, {
    int workerLimit = 2,
    Duration jobTimeout = const Duration(minutes: 2),
  }) : _workerLimit = workerLimit.clamp(1, 8),
       _jobTimeout = Duration(
         microseconds: math.max(1, jobTimeout.inMicroseconds),
       );

  Stream<PdfToImageEvent> convert(PdfToImageParams parameters) {
    late final StreamController<PdfToImageEvent> controller;
    _PdfConversionJob? ownedJob;
    controller = StreamController<PdfToImageEvent>(
      onListen: () {
        if (_running || _jobs.containsKey(parameters.jobId)) {
          controller.addError(
            const PdfConversionFailure(PdfConversionFailureCode.busy),
          );
          unawaited(controller.close());
          return;
        }
        final job = ownedJob = _PdfConversionJob(parameters, controller);
        _jobs[parameters.jobId] = job;
        _running = true;
        unawaited(_execute(job));
      },
      onCancel: () => ownedJob?.stop(),
    );
    return controller.stream;
  }

  Future<void> _execute(_PdfConversionJob job) async {
    Timer? deadline;
    var completed = false;
    try {
      final parameters = job.parameters;
      if (parameters.inputPaths.isEmpty ||
          parameters.inputPaths.length > 100 ||
          parameters.inputPaths.toSet().length !=
              parameters.inputPaths.length ||
          !['jpg', 'png', 'tiff'].contains(parameters.outputFormat) ||
          parameters.dpi < 72 ||
          parameters.dpi > 1200) {
        throw const PdfConversionFailure(
          PdfConversionFailureCode.invalidSettings,
        );
      }
      final runtime = await _runtimeLocator.resolve();
      job.check();
      job.directory = await Directory.systemTemp.createTemp('pixidesk_pdfium_');
      deadline = Timer(_jobTimeout, () {
        job.timedOut = true;
        unawaited(job.stop());
      });
      final inspector = await _startWorker(job, runtime);
      final pages = <_PdfPageTask>[];
      var totalInputBytes = 0;
      for (
        var documentIndex = 0;
        documentIndex < parameters.inputPaths.length;
        documentIndex++
      ) {
        job.check();
        final source = File(parameters.inputPaths[documentIndex]);
        final before = await source.stat();
        totalInputBytes += before.size;
        if (before.type != FileSystemEntityType.file || before.size < 1) {
          throw const PdfConversionFailure(
            PdfConversionFailureCode.invalidDocument,
          );
        }
        if (before.size > 256 * 1024 * 1024 ||
            totalInputBytes > 2 * 1024 * 1024 * 1024) {
          throw const PdfConversionFailure(
            PdfConversionFailureCode.resourceLimit,
          );
        }
        final snapshot = await source.copy(
          path.join(job.directory!.path, 'input-$documentIndex.pdf'),
        );
        final after = await source.stat();
        if (before.modified != after.modified || before.size != after.size) {
          throw const PdfConversionFailure(
            PdfConversionFailureCode.sourceChanged,
          );
        }
        job.check();
        final metadata = await inspector.request({
          'type': 'inspect',
          'sourcePath': snapshot.path,
        });
        final dimensions = (metadata['pages'] as List)
            .cast<Map<String, dynamic>>();
        if (dimensions.isEmpty ||
            dimensions.length > 5000 ||
            pages.length + dimensions.length > 10000) {
          throw const PdfConversionFailure(
            PdfConversionFailureCode.resourceLimit,
          );
        }
        final sourceName = String.fromCharCodes(
          path
              .basenameWithoutExtension(source.path)
              .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
              .runes
              .take(60),
        ).replaceAll(RegExp(r'[. ]+$'), '');
        for (var pageIndex = 0; pageIndex < dimensions.length; pageIndex++) {
          final width =
              ((dimensions[pageIndex]['width'] as num).toDouble() *
                      parameters.dpi /
                      72)
                  .ceil();
          final height =
              ((dimensions[pageIndex]['height'] as num).toDouble() *
                      parameters.dpi /
                      72)
                  .ceil();
          if (width <= 0 || height <= 0 || width * height > 160000000) {
            throw const PdfConversionFailure(
              PdfConversionFailureCode.resourceLimit,
            );
          }
          final outputPath = path.join(
            job.directory!.path,
            '${(documentIndex + 1).toString().padLeft(3, '0')}_${sourceName.isEmpty ? 'document' : sourceName}_page_${(pageIndex + 1).toString().padLeft(6, '0')}.${parameters.outputFormat}',
          );
          pages.add(
            _PdfPageTask(
              snapshot.path,
              source.path,
              pageIndex,
              width * height,
              outputPath,
            ),
          );
        }
      }
      job.check();
      final budget = await memoryBudgetBytes();
      final largestPage = pages.map((page) => page.pixelCount).reduce(math.max);
      final estimatedPerWorker = largestPage * 16 + 256 * 1024 * 1024;
      if (estimatedPerWorker > budget) {
        throw const PdfConversionFailure(
          PdfConversionFailureCode.resourceLimit,
        );
      }
      final workerCount = math.min(
        pages.length,
        math.min(
          math.max(1, Platform.numberOfProcessors - 1),
          math.min(_workerLimit, budget ~/ estimatedPerWorker),
        ),
      );
      for (var workerIndex = 1; workerIndex < workerCount; workerIndex++) {
        await _startWorker(job, runtime);
      }
      job.controller.add(
        PdfToImageProgress(
          ConversionProgress(
            currentPage: 0,
            totalPages: pages.length,
            percentage: 0,
          ),
        ),
      );
      var nextPage = 0;
      var finishedPages = 0;
      Object? workerError;
      await Future.wait(
        job.workers.map((worker) async {
          try {
            while (nextPage < pages.length && workerError == null) {
              job.check();
              final task = pages[nextPage++];
              final response = await worker.request({
                'type': 'render',
                'sourcePath': task.snapshotPath,
                'pageIndex': task.pageIndex,
                'dpi': parameters.dpi,
                'format': parameters.outputFormat,
                'outputPath': task.outputPath,
              });
              job.check();
              if (response['path'] != task.outputPath ||
                  response['previewPath'] != '${task.outputPath}.preview.png' ||
                  response['thumbnailPath'] != '${task.outputPath}.thumb.png' ||
                  !await _isNonemptyFile(task.outputPath) ||
                  !await _isNonemptyFile('${task.outputPath}.preview.png') ||
                  !await _isNonemptyFile('${task.outputPath}.thumb.png')) {
                throw const PdfConversionFailure(
                  PdfConversionFailureCode.workerFailed,
                );
              }
              finishedPages++;
              job.controller.add(
                PdfToImageProgress(
                  ConversionProgress(
                    currentPage: finishedPages,
                    totalPages: pages.length,
                    percentage: finishedPages / pages.length,
                  ),
                ),
              );
            }
          } catch (error) {
            workerError ??= error;
            await job.stopWorkers();
          }
        }),
      );
      job.check();
      if (workerError != null) throw workerError!;
      if (finishedPages != pages.length) {
        throw const PdfConversionFailure(PdfConversionFailureCode.workerFailed);
      }
      final grouped = <String, List<String>>{};
      for (final page in pages) {
        (grouped[page.sourcePath] ??= []).add(page.outputPath);
      }
      await job.stopWorkers();
      job.check();
      // Input snapshots are no longer needed; keep only completed review files.
      for (final file in job.directory!.listSync().whereType<File>().where(
        (file) => path.basename(file.path).startsWith('input-'),
      )) {
        await file.delete();
      }
      completed = true;
      job.controller.add(
        PdfToImageCompleted(
          List.unmodifiable(pages.map((page) => page.outputPath)),
          previewPaths: Map.unmodifiable({
            for (final page in pages)
              page.outputPath: '${page.outputPath}.preview.png',
          }),
          thumbnailPaths: Map.unmodifiable({
            for (final page in pages)
              page.outputPath: '${page.outputPath}.thumb.png',
          }),
          groupedPaths: Map.unmodifiable(
            grouped.map(
              (source, outputs) =>
                  MapEntry(source, List<String>.unmodifiable(outputs)),
            ),
          ),
        ),
      );
    } catch (error, stack) {
      if (!job.cancelled || job.timedOut) {
        final failure = job.timedOut
            ? const PdfConversionFailure(PdfConversionFailureCode.timedOut)
            : error is PdfConversionFailure
            ? error
            : PdfConversionFailure(
                error is FileSystemException
                    ? PdfConversionFailureCode.permissionDenied
                    : PdfConversionFailureCode.workerFailed,
              );
        job.controller.addError(failure, stack);
      }
    } finally {
      deadline?.cancel();
      await job.stopWorkers();
      if (!completed) await _removeDirectory(job.directory);
      _running = false;
      job.finished.complete();
      unawaited(job.controller.close());
    }
  }

  Future<PdfiumWorkerClient> _startWorker(
    _PdfConversionJob job,
    PdfiumRuntime runtime,
  ) async {
    job.check();
    final worker = await PdfiumWorkerClient.start(
      runtime,
      onSpawn: (worker) {
        job.workers.add(worker);
        if (job.cancelled) unawaited(worker.stop());
      },
    );
    if (job.cancelled) {
      await worker.stop();
      job.check();
    }
    return worker;
  }

  Future<void> cancel(String jobId) async {
    final job = _jobs[jobId];
    if (job == null) return;
    await job.stop();
    await job.finished.future;
    await job.controller.done;
  }

  Future<void> release(String jobId) async {
    final job = _jobs[jobId];
    if (job == null) return;
    if (!job.finished.isCompleted) await cancel(jobId);
    await _removeDirectory(job.directory);
    _jobs.remove(jobId);
  }

  static Future<bool> _isNonemptyFile(String filePath) async {
    final file = File(filePath);
    return await file.exists() && await file.length() > 0;
  }

  static Future<void> _removeDirectory(Directory? directory) async {
    try {
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } on FileSystemException {
      /* Never remove unrelated temporary directories. */
    }
  }

  static Future<int> memoryBudgetBytes() async {
    const fallback = 1024 * 1024 * 1024;
    try {
      int physicalMemory;
      if (Platform.isLinux) {
        final match = RegExp(
          r'^MemTotal:\s+(\d+)',
          multiLine: true,
        ).firstMatch(await File('/proc/meminfo').readAsString());
        physicalMemory = int.parse(match!.group(1)!) * 1024;
      } else {
        final result = Platform.isMacOS
            ? await Process.run('/usr/sbin/sysctl', [
                '-n',
                'hw.memsize',
              ]).timeout(const Duration(seconds: 5))
            : await Process.run('powershell.exe', [
                '-NoProfile',
                '-NonInteractive',
                '-Command',
                '(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory',
              ]).timeout(const Duration(seconds: 5));
        physicalMemory = int.parse(result.stdout.toString().trim());
      }
      return math.min(4 * 1024 * 1024 * 1024, (physicalMemory * .4).floor());
    } catch (_) {
      return fallback;
    }
  }
}

class _PdfPageTask {
  final String snapshotPath, sourcePath, outputPath;
  final int pageIndex, pixelCount;
  const _PdfPageTask(
    this.snapshotPath,
    this.sourcePath,
    this.pageIndex,
    this.pixelCount,
    this.outputPath,
  );
}

class _PdfConversionJob {
  final PdfToImageParams parameters;
  final StreamController<PdfToImageEvent> controller;
  final workers = <PdfiumWorkerClient>[];
  final finished = Completer<void>();
  Directory? directory;
  bool cancelled = false, timedOut = false;
  _PdfConversionJob(this.parameters, this.controller);
  void check() {
    if (cancelled) {
      throw const PdfConversionFailure(PdfConversionFailureCode.cancelled);
    }
  }

  Future<void> stopWorkers() async {
    await Future.wait(workers.toList().map((worker) => worker.stop()));
  }

  Future<void> stop() async {
    cancelled = true;
    await stopWorkers();
  }
}
