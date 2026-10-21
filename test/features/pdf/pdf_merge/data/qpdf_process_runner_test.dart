import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/qpdf_process_runner.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/qpdf_runtime.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_failure.dart';

class RuntimeMock extends Mock implements QpdfRuntimeLocator {}

void main() {
  group(
    'native child lifecycle',
    () {
      late Directory fixtures;
      late RuntimeMock runtime;
      late QpdfProcessRunner runner;
      setUp(() async {
        fixtures = await Directory.systemTemp.createTemp('qpdf_process_test_');
        runtime = RuntimeMock();
        runner = QpdfProcessRunner(runtime);
      });
      tearDown(() async {
        await runner.cancel();
        await fixtures.delete(recursive: true);
      });
      Future<void> executable(String body) async {
        final binary = File('${fixtures.path}/fake-qpdf');
        await binary.writeAsString('#!/bin/sh\n$body\n');
        expect(
          (await Process.run('/bin/chmod', ['700', binary.path])).exitCode,
          0,
        );
        when(() => runtime.resolve()).thenAnswer((_) async => binary.path);
      }

      Matcher failure(PdfMergeFailureCode code) =>
          isA<PdfMergeFailure>().having((error) => error.code, 'code', code);
      test('cancels a pending runtime lookup before native startup', () async {
        final lookup = Completer<String>();
        when(() => runtime.resolve()).thenAnswer((_) => lookup.future);
        final pending = runner.run({'password': 'private'});
        final expectation = expectLater(
          pending,
          throwsA(failure(PdfMergeFailureCode.cancelled)),
        );
        await runner.cancel();
        lookup.complete('/does/not/exist');
        await expectation;
      });
      test(
        'timeout kills the process and removes private credential configuration',
        () async {
          await executable(
            'printf "%s" "\$1" > "${fixtures.path}/argv"\nexec sleep 30',
          );
          await expectLater(
            runner.run({
              'password': 'private',
            }, timeout: const Duration(seconds: 1)),
            throwsA(failure(PdfMergeFailureCode.timedOut)),
          );
          final argument = File('${fixtures.path}/argv').readAsStringSync();
          expect(argument, isNot(contains('private')));
          final configuration = File(
            argument.substring('--job-json-file='.length),
          );
          expect(configuration.existsSync(), isFalse);
          expect(configuration.parent.existsSync(), isFalse);
        },
      );
      test('oversized output is bounded before line splitting', () async {
        await executable('head -c 1100000 /dev/zero >&2');
        await expectLater(
          runner.run({}),
          throwsA(failure(PdfMergeFailureCode.resourceLimit)),
        );
      });
    },
    skip: Platform.isWindows
        ? 'POSIX process fixtures; actual Windows runtime needs Windows execution.'
        : false,
  );
}
