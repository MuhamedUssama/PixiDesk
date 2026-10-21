import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/qpdf_runtime.dart';

void main() {
  late Directory fixtures;
  setUp(
    () async =>
        fixtures = await Directory.systemTemp.createTemp('qpdf_runtime_test_'),
  );
  tearDown(() => fixtures.delete(recursive: true));
  for (final operatingSystem in ['macos', 'windows', 'linux']) {
    for (final architecture in ['arm64', 'x64']) {
      test(
        'verifies bundled $operatingSystem-$architecture and rejects tampering/traversal',
        () async {
          final executable = path.join(
            fixtures.path,
            'App/Contents/MacOS/pixidesk',
          );
          final directory = Directory(
            operatingSystem == 'macos'
                ? path.normalize(
                    path.join(
                      path.dirname(executable),
                      '../Helpers/PixiDeskQPDF',
                      architecture,
                    ),
                  )
                : path.join(path.dirname(executable), 'qpdf'),
          )..createSync(recursive: true);
          final binaryName = operatingSystem == 'windows'
              ? 'bin/qpdf.exe'
              : 'bin/qpdf';
          final binary = File(path.join(directory.path, binaryName));
          binary.parent.createSync();
          binary.writeAsStringSync('native-tool-fixture');
          final manifest = File(path.join(directory.path, 'runtime.json'));
          final metadata = <String, Object>{
            'version': '12.4.2',
            'target': '$operatingSystem-$architecture',
            'executable': binaryName,
            'files': {
              binaryName: sha256.convert(binary.readAsBytesSync()).toString(),
            },
          };
          manifest.writeAsStringSync(jsonEncode(metadata));
          expect(
            await QpdfRuntimeLocator.resolveAt(
              executable,
              operatingSystem,
              architecture,
            ),
            binary.path,
          );
          binary.writeAsStringSync('tampered');
          await expectLater(
            QpdfRuntimeLocator.resolveAt(
              executable,
              operatingSystem,
              architecture,
            ),
            throwsFormatException,
          );
          metadata['executable'] = '../../outside';
          metadata['files'] = {'../../outside': 'ignored'};
          manifest.writeAsStringSync(jsonEncode(metadata));
          await expectLater(
            QpdfRuntimeLocator.resolveAt(
              executable,
              operatingSystem,
              architecture,
            ),
            throwsFormatException,
          );
          metadata['target'] = 'wrong-platform';
          manifest.writeAsStringSync(jsonEncode(metadata));
          await expectLater(
            QpdfRuntimeLocator.resolveAt(
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
