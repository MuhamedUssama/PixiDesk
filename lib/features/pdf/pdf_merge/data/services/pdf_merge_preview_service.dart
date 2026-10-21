import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../../shared/data/pdfium/pdfium_runtime.dart';
import '../../../shared/data/pdfium/pdfium_worker_client.dart';
import '../../domain/entities/pdf_merge_document.dart';
import '../../domain/entities/pdf_merge_failure.dart';

@injectable
class PdfMergePreviewService {
  final PdfiumRuntimeLocator _runtime;
  PdfiumWorkerClient? _worker;
  Directory? _directory;
  final Map<String, String> _cache = {};
  int _generation = 0;
  Future<void> _pending = Future.value();
  bool _busy = false;
  bool _closed = false;
  PdfMergePreviewService(this._runtime);

  Future<String> render(
    PdfMergeDocument document,
    int pageIndex,
    String? password,
  ) {
    final generation = ++_generation;
    if (_busy) unawaited(_stopWorker());
    final previous = _pending;
    final result = _render(document, pageIndex, password, generation, previous);
    _pending = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<String> _render(
    PdfMergeDocument document,
    int pageIndex,
    String? password,
    int generation,
    Future<void> previous,
  ) async {
    PdfiumWorkerClient? activeWorker;
    String? output;
    var retained = false;
    void checkCancelled() {
      if (_closed || generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
    }

    try {
      // Serial ownership prevents an old worker startup/cleanup from replacing
      // or stopping the next request's worker. New intent still kills active work.
      await previous;
      checkCancelled();
      if (pageIndex < 0 || pageIndex >= document.pageCount) {
        throw const PdfMergeFailure(PdfMergeFailureCode.previewUnavailable);
      }
      final key = '${document.id}-$pageIndex';
      final cached = _cache[key];
      if (cached != null && await File(cached).exists()) {
        checkCancelled();
        _cache.remove(key);
        _cache[key] = cached;
        return cached;
      }
      _busy = true;
      final runtime = await _runtime.resolve();
      checkCancelled();
      _directory ??= await Directory.systemTemp.createTemp(
        'pixidesk_merge_preview_',
      );
      checkCancelled();
      if (_worker == null) {
        final started = await PdfiumWorkerClient.start(
          runtime,
          onSpawn: (worker) {
            activeWorker = worker;
            if (_closed || generation != _generation) {
              unawaited(worker.stop());
            } else {
              _worker = worker;
            }
          },
        );
        activeWorker = started;
        checkCancelled();
        _worker = started;
      }
      final worker = activeWorker = _worker!;
      output = path.join(_directory!.path, '$key-$generation.png');
      final response = await worker.request({
        'type': 'render',
        'sourcePath': document.path,
        'pageIndex': pageIndex,
        'dpi': 144,
        'maxDimension': 1400,
        'format': 'png',
        'includePreviewAssets': false,
        'outputPath': output,
        if (password != null) 'password': password,
      });
      checkCancelled();
      if (response['path'] != output || !await File(output).exists()) {
        throw const PdfMergeFailure(PdfMergeFailureCode.previewUnavailable);
      }
      checkCancelled();
      _cache[key] = output;
      while (_cache.length > 24) {
        final expired = _cache.remove(_cache.keys.first)!;
        await _deletePreview(expired);
      }
      retained = true;
      return output;
    } on PdfMergeFailure {
      rethrow;
    } catch (_) {
      if (identical(activeWorker, _worker)) await _stopWorker();
      checkCancelled();
      throw const PdfMergeFailure(PdfMergeFailureCode.previewUnavailable);
    } finally {
      if (!retained && activeWorker != null) {
        if (identical(activeWorker, _worker)) _worker = null;
        await activeWorker!.stop();
      }
      if (!retained && output != null) await _deletePreview(output);
      if (generation == _generation) _busy = false;
    }
  }

  Future<void> _deletePreview(String output) async {
    for (final suffix in ['', '.partial', '.preview.png', '.thumb.png']) {
      try {
        final file = File('$output$suffix');
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // The session directory is also removed on disposal.
      }
    }
  }

  Future<void> _stopWorker() async {
    final worker = _worker;
    _worker = null;
    await worker?.stop();
  }

  Future<void> cancel() async {
    _generation++;
    _busy = false;
    await _stopWorker();
    await _pending;
  }

  Future<void> dispose() async {
    _closed = true;
    await cancel();
    _cache.clear();
    final directory = _directory;
    _directory = null;
    if (directory != null && await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
