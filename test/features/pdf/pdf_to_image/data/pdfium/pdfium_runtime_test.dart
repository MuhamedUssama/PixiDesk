import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_runtime.dart';

void main() {
  late Directory fixtures;
  setUp(() async {
    fixtures = await Directory.systemTemp.createTemp('pdf_runtime_test_');
  });
  tearDown(() => fixtures.delete(recursive: true));
  test(
    'macOS versions below the pinned binary minimum are rejected explicitly',
    () {
      expect(
        () => PdfiumRuntimeLocator.ensureSupportedOperatingSystem(
          'macos',
          'Version 12.7.6 (Build 21H1320)',
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => PdfiumRuntimeLocator.ensureSupportedOperatingSystem(
          'macos',
          'Version 13.0 (Build 22A380)',
        ),
        returnsNormally,
      );
      expect(
        () => PdfiumRuntimeLocator.ensureSupportedOperatingSystem(
          'windows',
          'Windows 10',
        ),
        returnsNormally,
      );
    },
  );
  for (final operatingSystem in ['windows', 'macos', 'linux']) {
    for (final architecture in ['x64', 'arm64']) {
      test(
        'resolves bundled $operatingSystem $architecture without a Dart SDK',
        () async {
          final executable = operatingSystem == 'macos'
              ? path.join(
                  fixtures.path,
                  'PixiDesk.app/Contents/MacOS/pixi_desk',
                )
              : path.join(fixtures.path, 'pixi_desk');
          final executableDirectory = path.dirname(executable);
          final runtime = Directory(
            operatingSystem == 'macos'
                ? path.normalize(
                    path.join(
                      executableDirectory,
                      '../Frameworks/PixiDeskPDFium',
                    ),
                  )
                : path.join(executableDirectory, 'pdfium'),
          )..createSync(recursive: true);
          final worker = File(
            operatingSystem == 'macos'
                ? path.normalize(
                    path.join(
                      executableDirectory,
                      '../Helpers/pixidesk_pdf_worker_$architecture',
                    ),
                  )
                : path.join(
                    runtime.path,
                    operatingSystem == 'windows'
                        ? 'pixidesk_pdf_worker.exe'
                        : 'pixidesk_pdf_worker',
                  ),
          );
          worker.parent.createSync(recursive: true);
          worker.writeAsStringSync('fixture');
          final library = File(path.join(runtime.path, 'library'))
            ..writeAsStringSync('pdfium');
          final manifest = File(path.join(runtime.path, 'runtime.json'))
            ..writeAsStringSync(
              jsonEncode({
                'revision': 'chromium/8100',
                'library': 'library',
                'librarySha256': sha256
                    .convert(library.readAsBytesSync())
                    .toString(),
              }),
            );
          final resolved = await PdfiumRuntimeLocator.resolveAt(
            executable,
            operatingSystem,
            architecture,
          );
          expect(resolved.executable, worker.path);
          expect(resolved.libraryPath, library.path);
          expect(resolved.arguments, isEmpty);
          library.writeAsStringSync('tampered');
          await expectLater(
            PdfiumRuntimeLocator.resolveAt(
              executable,
              operatingSystem,
              architecture,
            ),
            throwsFormatException,
          );
          manifest.writeAsStringSync(
            jsonEncode({
              'revision': 'chromium/8100',
              'library': '../outside',
              'librarySha256': 'ignored',
            }),
          );
          await expectLater(
            PdfiumRuntimeLocator.resolveAt(
              executable,
              operatingSystem,
              architecture,
            ),
            throwsFormatException,
          );
        },
      );
    }
  }
}
