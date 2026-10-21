import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../domain/entities/pdf_conversion_failure.dart';
import 'pdfium_runtime.dart';

class PdfiumWorkerClient {
  final Process _process;
  final _ready = Completer<void>();
  Completer<Map<String, dynamic>>? _pending;
  StreamSubscription<String>? _output;
  StreamSubscription<List<int>>? _errors;
  Future<void>? _stopping;
  var _requestId = 0;
  PdfiumWorkerClient._(this._process) {
    _output = _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          _onLine,
          onError: (Object error) =>
              _fail(PdfConversionFailureCode.workerFailed),
        );
    _errors = _process.stderr.listen((_) {}, onError: (Object error) {});
    unawaited(
      _process.exitCode.then(
        (_) => _fail(
          _stopping == null
              ? PdfConversionFailureCode.workerFailed
              : PdfConversionFailureCode.cancelled,
        ),
      ),
    );
  }

  static Future<PdfiumWorkerClient> start(
    PdfiumRuntime runtime, {
    Duration timeout = const Duration(seconds: 30),
    void Function(PdfiumWorkerClient)? onSpawn,
  }) async {
    PdfiumWorkerClient? worker;
    try {
      worker = PdfiumWorkerClient._(
        await Process.start(runtime.executable, [
          ...runtime.arguments,
          runtime.libraryPath,
        ], runInShell: false),
      );
      final readiness = worker._ready.future.timeout(timeout);
      onSpawn?.call(worker);
      await readiness;
      return worker;
    } catch (_) {
      await worker?.stop();
      throw const PdfConversionFailure(
        PdfConversionFailureCode.engineUnavailable,
      );
    }
  }

  void _onLine(String line) {
    try {
      if (line.length > 4 * 1024 * 1024) {
        throw const FormatException('Protocol limit');
      }
      final message = jsonDecode(line) as Map<String, dynamic>;
      if (message['type'] == 'ready') {
        if (message['protocol'] != 1 ||
            message['revision'] != 'chromium/8100') {
          throw const FormatException('Protocol mismatch');
        }
        if (!_ready.isCompleted) _ready.complete();
        return;
      }
      final pending = _pending;
      if (pending == null ||
          pending.isCompleted ||
          message['id'] != _requestId) {
        throw const FormatException('Unexpected response');
      }
      if (message['error'] != null) {
        final code =
            PdfConversionFailureCode.values
                .where((value) => value.name == message['error'])
                .firstOrNull ??
            PdfConversionFailureCode.workerFailed;
        pending.completeError(PdfConversionFailure(code));
      } else {
        pending.complete(message['result'] as Map<String, dynamic>);
      }
    } catch (_) {
      _fail(PdfConversionFailureCode.workerFailed);
      unawaited(stop());
    }
  }

  Future<Map<String, dynamic>> request(
    Map<String, Object> parameters, {
    Duration timeout = const Duration(minutes: 2),
  }) async {
    if (_stopping != null) {
      throw const PdfConversionFailure(PdfConversionFailureCode.cancelled);
    }
    if (_pending != null) {
      throw const PdfConversionFailure(PdfConversionFailureCode.busy);
    }
    final response = Completer<Map<String, dynamic>>();
    _pending = response;
    _requestId++;
    try {
      _process.stdin.writeln(jsonEncode({...parameters, 'id': _requestId}));
      return await response.future.timeout(timeout);
    } on TimeoutException {
      await stop();
      throw const PdfConversionFailure(PdfConversionFailureCode.timedOut);
    } finally {
      _pending = null;
    }
  }

  void _fail(PdfConversionFailureCode code) {
    final error = PdfConversionFailure(code);
    if (!_ready.isCompleted) _ready.completeError(error);
    if (_pending case final pending? when !pending.isCompleted) {
      pending.completeError(error);
    }
  }

  Future<void> stop() => _stopping ??= _stop();
  Future<void> _stop() async {
    _fail(PdfConversionFailureCode.cancelled);
    _process.kill(ProcessSignal.sigkill);
    try {
      await _process.exitCode.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      _process.kill(ProcessSignal.sigkill);
    }
    await _output?.cancel();
    await _errors?.cancel();
    await _process.stdin
        .close()
        .timeout(const Duration(seconds: 2))
        .catchError((Object _) {});
  }
}
