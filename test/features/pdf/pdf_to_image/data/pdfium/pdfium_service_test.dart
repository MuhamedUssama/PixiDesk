import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:path/path.dart' as path;
import 'package:pixi_desk/features/pdf/pdf_to_image/data/pdfium/pdfium_conversion_service.dart';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_runtime.dart';
import 'package:pixi_desk/features/pdf/shared/domain/entities/pdf_processing_failure.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';

void main() {
  final hostTarget = Platform.isMacOS
      ? 'macos'
      : '${Platform.operatingSystem}-${Platform.version.contains('arm64') ? 'arm64' : 'x64'}';
  final hasRuntime = File(
    path.join('native/pdfium/runtime', hostTarget, 'runtime.json'),
  ).existsSync();
  group(
    'real PDFium subprocess conversion',
    () {
      late Directory fixtures;
      late PdfiumConversionService service;
      Future<File> makePdf(
        String name,
        int pages, {
        double pageSize = 144,
      }) async {
        final document = pdf_widgets.Document();
        for (var index = 0; index < pages; index++) {
          document.addPage(
            pdf_widgets.Page(
              pageFormat: PdfPageFormat(pageSize, pageSize),
              margin: pdf_widgets.EdgeInsets.zero,
              build: (_) => pdf_widgets.Container(
                color: index.isEven
                    ? const PdfColor(1, 0, 0)
                    : const PdfColor(0, 0, 1),
              ),
            ),
          );
        }
        return File(path.join(fixtures.path, name))
          ..writeAsBytesSync(await document.save());
      }

      setUp(() async {
        fixtures = await Directory.systemTemp.createTemp(
          'pixidesk_pdfium_test_',
        );
        service = PdfiumConversionService.testing(PdfiumRuntimeLocator());
      });
      tearDown(() async {
        await fixtures.delete(recursive: true);
      });

      for (final format in ['png', 'jpg', 'tiff']) {
        test(
          'renders actual $format content in document/page order with accurate progress',
          () async {
            addTearDown(() => service.release(format));
            final first = await makePdf('same name عربي.pdf', 3);
            final nested = Directory(path.join(fixtures.path, 'other'))
              ..createSync();
            final second = await makePdf('second.pdf', 2);
            final sameName = await second.copy(
              path.join(nested.path, path.basename(first.path)),
            );
            final original = first.readAsBytesSync();
            final events = await service
                .convert(
                  PdfToImageParams(
                    jobId: format,
                    inputPaths: [first.path, sameName.path],
                    outputFormat: format,
                    dpi: 72,
                  ),
                )
                .toList();
            final completed = events.whereType<PdfToImageCompleted>().single;
            final progress = events.whereType<PdfToImageProgress>().toList();
            expect(progress.map((event) => event.progress.currentPage), [
              0,
              1,
              2,
              3,
              4,
              5,
            ]);
            expect(progress.last.progress.totalPages, 5);
            expect(completed.groupedPaths[first.path]!.length, 3);
            expect(completed.groupedPaths[sameName.path]!.length, 2);
            expect(completed.imagePaths.toSet().length, 5);
            expect(completed.imagePaths[0], contains('001_'));
            expect(completed.imagePaths[3], contains('002_'));
            for (var index = 0; index < 5; index++) {
              final bytes = File(completed.imagePaths[index]).readAsBytesSync();
              final decoded = image_codec.decodeImage(bytes)!;
              expect(decoded.width, 144);
              expect(decoded.height, 144);
              final pixel = decoded.getPixel(72, 72);
              final expectedRed = index == 0 || index == 2 || index == 3;
              expect(expectedRed ? pixel.r : pixel.b, greaterThan(240));
              expect(expectedRed ? pixel.b : pixel.r, lessThan(15));
              expect(
                image_codec.findDecoderForData(bytes)!.format.name,
                format == 'jpg' ? 'jpg' : format,
              );
            }
            for (final previewPath in [
              ...completed.previewPaths.values,
              ...completed.thumbnailPaths.values,
            ]) {
              expect(
                image_codec.decodePng(File(previewPath).readAsBytesSync()),
                isNotNull,
              );
            }
            expect(first.readAsBytesSync(), original);
            await service.release(format);
            expect(File(completed.imagePaths.first).existsSync(), isFalse);
            expect(first.existsSync(), isTrue);
          },
        );
      }
      test(
        'replaces the false single-page fallback with a typed invalid-document failure',
        () async {
          final invalid = File(path.join(fixtures.path, 'invalid.pdf'))
            ..writeAsStringSync('not a PDF');
          await expectLater(
            service
                .convert(
                  PdfToImageParams(jobId: 'bad', inputPaths: [invalid.path]),
                )
                .toList(),
            throwsA(
              isA<PdfProcessingFailure>().having(
                (failure) => failure.code,
                'code',
                PdfProcessingFailureCode.invalidDocument,
              ),
            ),
          );
          await service.release('bad');
        },
      );
      test('rejects an oversized raster before allocating it', () async {
        final huge = await makePdf('huge.pdf', 1, pageSize: 100000);
        await expectLater(
          service
              .convert(
                PdfToImageParams(
                  jobId: 'huge',
                  inputPaths: [huge.path],
                  dpi: 1200,
                ),
              )
              .toList(),
          throwsA(
            isA<PdfProcessingFailure>().having(
              (failure) => failure.code,
              'code',
              PdfProcessingFailureCode.resourceLimit,
            ),
          ),
        );
        await service.release('huge');
      });
      test(
        'cancellation stops child workers, removes partial output, and allows another run',
        () async {
          final source = await makePdf('cancel.pdf', 20);
          final results = <PdfToImageEvent>[];
          final cancelled = Completer<void>();
          final streamFinished = Completer<void>();
          final subscription = service
              .convert(
                PdfToImageParams(
                  jobId: 'cancel',
                  inputPaths: [source.path],
                  dpi: 150,
                ),
              )
              .listen(
                (event) {
                  results.add(event);
                  if (!cancelled.isCompleted &&
                      event is PdfToImageProgress &&
                      event.progress.currentPage >= 1) {
                    cancelled.complete();
                    unawaited(service.cancel('cancel'));
                  }
                },
                onDone: streamFinished.complete,
                onError: (Object error, StackTrace stack) =>
                    streamFinished.completeError(error, stack),
              );
          await cancelled.future.timeout(const Duration(seconds: 30));
          await streamFinished.future.timeout(const Duration(seconds: 15));
          expect(results.whereType<PdfToImageCompleted>(), isEmpty);
          await subscription.cancel();
          await service.release('cancel');
          final retry = await service
              .convert(
                PdfToImageParams(
                  jobId: 'retry',
                  inputPaths: [source.path],
                  dpi: 72,
                ),
              )
              .toList();
          expect(
            retry.whereType<PdfToImageCompleted>().single.imagePaths.length,
            20,
          );
          await service.release('retry');
        },
      );
      for (final rejectedId in ['second', 'first']) {
        test(
          'overlapping job $rejectedId cannot cancel or delete the first results',
          () async {
            final source = await makePdf('busy.pdf', 1);
            addTearDown(() => service.release('first'));
            final first = service
                .convert(
                  PdfToImageParams(
                    jobId: 'first',
                    inputPaths: [source.path],
                    dpi: 72,
                  ),
                )
                .toList();
            await expectLater(
              service
                  .convert(
                    PdfToImageParams(
                      jobId: rejectedId,
                      inputPaths: [source.path],
                    ),
                  )
                  .toList(),
              throwsA(
                isA<PdfProcessingFailure>().having(
                  (failure) => failure.code,
                  'code',
                  PdfProcessingFailureCode.busy,
                ),
              ),
            );
            final completion = (await first)
                .whereType<PdfToImageCompleted>()
                .single;
            expect(File(completion.imagePaths.single).existsSync(), isTrue);
          },
        );
      }
      test('whole-job timeout stops a worker during startup', () async {
        final source = await makePdf('deadline.pdf', 1);
        service = PdfiumConversionService.testing(
          PdfiumRuntimeLocator(),
          jobTimeout: const Duration(milliseconds: 20),
        );
        addTearDown(() => service.release('deadline'));
        await expectLater(
          service
              .convert(
                PdfToImageParams(jobId: 'deadline', inputPaths: [source.path]),
              )
              .toList(),
          throwsA(
            isA<PdfProcessingFailure>().having(
              (failure) => failure.code,
              'code',
              PdfProcessingFailureCode.timedOut,
            ),
          ),
        );
      });
    },
    skip: hasRuntime
        ? false
        : 'Run python3 tool/prepare_pdfium.py --target host to enable native PDFium smoke tests.',
  );
}
