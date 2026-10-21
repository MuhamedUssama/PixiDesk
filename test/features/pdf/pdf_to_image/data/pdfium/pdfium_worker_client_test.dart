import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_runtime.dart';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_worker_client.dart';
import 'package:pixi_desk/features/pdf/shared/domain/entities/pdf_processing_failure.dart';

void main() {
  late Directory fixtures;
  late String dartExecutable;
  setUp(() async {
    fixtures = await Directory.systemTemp.createTemp('pdf_protocol_test_');
    final dartName = Platform.isWindows ? 'dart.exe' : 'dart';
    dartExecutable = (Platform.environment['PATH'] ?? '')
        .split(Platform.isWindows ? ';' : ':')
        .map((directory) => path.join(directory, dartName))
        .firstWhere((candidate) => File(candidate).existsSync());
  });
  tearDown(() => fixtures.delete(recursive: true));
  Future<PdfiumRuntime> fakeRuntime(String body) async {
    final script = File(path.join(fixtures.path, 'fake_worker.dart'))
      ..writeAsStringSync(
        "import 'dart:io'; import 'dart:convert'; import 'dart:async'; Future<void> main(List<String> arguments) async { $body }",
      );
    return PdfiumRuntime(
      executable: dartExecutable,
      arguments: [script.path],
      libraryPath: 'unused',
    );
  }

  const ready =
      "stdout.writeln(jsonEncode({'type':'ready','protocol':1,'revision':'chromium/8100'}));";
  test(
    'malformed responses fail the pending request and stop the process',
    () async {
      final worker = await PdfiumWorkerClient.start(
        await fakeRuntime(
          "$ready await for(final line in stdin.transform(utf8.decoder).transform(const LineSplitter())) { stdout.writeln('malformed'); }",
        ),
      );
      addTearDown(worker.stop);
      await expectLater(
        worker.request({'type': 'inspect'}),
        throwsA(
          isA<PdfProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            PdfProcessingFailureCode.workerFailed,
          ),
        ),
      );
    },
  );
  test(
    'a crashed helper fails promptly instead of leaving a pending request',
    () async {
      final worker = await PdfiumWorkerClient.start(
        await fakeRuntime("$ready await stdin.first; exit(7);"),
      );
      addTearDown(worker.stop);
      await expectLater(
        worker.request({'type': 'inspect'}),
        throwsA(
          isA<PdfProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            PdfProcessingFailureCode.workerFailed,
          ),
        ),
      );
    },
  );
  test('request timeout kills a stalled helper', () async {
    final worker = await PdfiumWorkerClient.start(
      await fakeRuntime(
        "$ready await for(final line in stdin) { await Future<void>.delayed(const Duration(minutes:10)); }",
      ),
    );
    addTearDown(worker.stop);
    await expectLater(
      worker.request({
        'type': 'inspect',
      }, timeout: const Duration(milliseconds: 100)),
      throwsA(
        isA<PdfProcessingFailure>().having(
          (failure) => failure.code,
          'code',
          PdfProcessingFailureCode.timedOut,
        ),
      ),
    );
    await worker.stop();
  });
  test('cancellation can stop a helper before its ready handshake', () async {
    final runtime = await fakeRuntime(
      'await Future<void>.delayed(const Duration(minutes:10));',
    );
    final watch = Stopwatch()..start();
    await expectLater(
      PdfiumWorkerClient.start(
        runtime,
        onSpawn: (worker) => unawaited(worker.stop()),
      ),
      throwsA(isA<PdfProcessingFailure>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
