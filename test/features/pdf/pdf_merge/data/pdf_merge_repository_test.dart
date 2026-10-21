import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixi_desk/core/di/injection.config.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/services/pdf_merge_desktop_gateway.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_action.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_state.dart';
import 'package:image/image.dart' as image_codec;
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:pixi_desk/features/pdf/pdf_merge/data/repositories/pdf_merge_repository_impl.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/pdf_merge_preview_service.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/qpdf_process_runner.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/data/services/qpdf_runtime.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_failure.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_request.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_event.dart';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_runtime.dart';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_worker_client.dart';

class TestMergeDesktop implements PdfMergeDesktopGateway {
  final String destination;
  TestMergeDesktop(this.destination);
  @override
  Future<List<String>> selectDocuments() async => [];
  @override
  Future<String?> selectDestination(String title) async => destination;
  @override
  Future<void> openDocument(String path) async {}
  @override
  Future<void> revealDocument(String path) async {}
}

void main() {
  final architecture = Abi.current().toString().contains('arm64')
      ? 'arm64'
      : 'x64';
  final runtimeAvailable = File(
    'native/qpdf/runtime/${Platform.operatingSystem}-$architecture/runtime.json',
  ).existsSync();
  group(
    'actual QPDF merge engine',
    () {
      late Directory fixtures;
      late PdfMergeRepositoryImpl repository;
      late QpdfProcessRunner runner;
      setUp(() async {
        fixtures = await Directory.systemTemp.createTemp('pdf_merge_test_');
        runner = QpdfProcessRunner(QpdfRuntimeLocator());
        repository = PdfMergeRepositoryImpl(
          runner,
          PdfMergePreviewService(PdfiumRuntimeLocator()),
        );
      });
      tearDown(() async {
        await repository.dispose();
        await fixtures.delete(recursive: true);
      });
      Future<File> pdf(
        String filename,
        List<PdfColor> colors, {
        PdfPageFormat pageFormat = const PdfPageFormat(144, 72),
      }) async {
        final document = pdf_widgets.Document();
        for (final color in colors) {
          document.addPage(
            pdf_widgets.Page(
              pageFormat: pageFormat,
              margin: pdf_widgets.EdgeInsets.zero,
              build: (_) => pdf_widgets.Container(color: color),
            ),
          );
        }
        return File(path.join(fixtures.path, filename))
          ..writeAsBytesSync(await document.save());
      }

      test(
        'merges selected pages in document order, retains rotations and renders real output',
        () async {
          final first = await pdf('first عربي.pdf', [
            const PdfColor(1, 0, 0),
            const PdfColor(0, 0, 1),
          ]);
          final second = await pdf('second.pdf', [const PdfColor(0, 1, 0)]);
          final original = await first.readAsBytes();
          final a = await repository.inspect(first.path);
          final b = await repository.inspect(second.path);
          final events = await repository
              .merge(
                PdfMergeRequest(
                  documents: [
                    b,
                    a.copyWith(selectedPages: [1, 0, 1], rotations: {1: 1}),
                  ],
                  destinationPath: path.join(fixtures.path, 'merged.pdf'),
                  acknowledgeDocumentChanges: true,
                ),
              )
              .toList();
          final result = events.whereType<PdfMergeCompleted>().single.result;
          expect(result.pageCount, 4);
          expect(first.readAsBytesSync(), original);
          expect(
            events.whereType<PdfMergeProgress>().map((event) => event.stage),
            containsAllInOrder([
              PdfMergeStage.preparing,
              PdfMergeStage.merging,
              PdfMergeStage.validating,
              PdfMergeStage.saving,
            ]),
          );
          expect(
            (await runner.run({'inputFile': result.path, 'check': ''})),
            contains('No syntax or stream encoding errors'),
          );
          final runtime = await PdfiumRuntimeLocator().resolve();
          final worker = await PdfiumWorkerClient.start(runtime);
          addTearDown(worker.stop);
          for (var index = 0; index < 4; index++) {
            final output = path.join(fixtures.path, 'page-$index.png');
            await worker.request({
              'type': 'render',
              'sourcePath': result.path,
              'pageIndex': index,
              'dpi': 72,
              'format': 'png',
              'outputPath': output,
            });
            final pixels = image_codec.decodePng(
              File(output).readAsBytesSync(),
            )!;
            expect(pixels.width, index.isOdd ? 72 : 144);
            expect(pixels.height, index.isOdd ? 144 : 72);
            final center = pixels.getPixel(
              pixels.width ~/ 2,
              pixels.height ~/ 2,
            );
            expect(
              index == 0
                  ? center.g
                  : index.isOdd
                  ? center.b
                  : center.r,
              greaterThan(240),
            );
          }
        },
      );
      test(
        'source aliases and existing destinations are protected without partial files',
        () async {
          final source = await pdf('source.pdf', [const PdfColor(1, 0, 0)]);
          final document = await repository.inspect(source.path);
          final original = source.readAsBytesSync();
          await expectLater(
            repository
                .merge(
                  PdfMergeRequest(
                    documents: [document],
                    destinationPath: source.path,
                    acknowledgeDocumentChanges: true,
                  ),
                )
                .toList(),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.sourceProtected,
              ),
            ),
          );
          final existing = File(path.join(fixtures.path, 'existing.pdf'))
            ..writeAsStringSync('keep me');
          await expectLater(
            repository
                .merge(
                  PdfMergeRequest(
                    documents: [document],
                    destinationPath: existing.path,
                    acknowledgeDocumentChanges: true,
                  ),
                )
                .toList(),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.destinationConflict,
              ),
            ),
          );
          expect(source.readAsBytesSync(), original);
          expect(existing.readAsStringSync(), 'keep me');
          expect(fixtures.listSync().whereType<Directory>(), isEmpty);
        },
      );
      test('detects source edits after inspection', () async {
        final source = await pdf('source.pdf', [const PdfColor(1, 0, 0)]);
        final document = await repository.inspect(source.path);
        source.writeAsStringSync('changed');
        await expectLater(
          repository
              .merge(
                PdfMergeRequest(
                  documents: [document],
                  destinationPath: path.join(fixtures.path, 'out.pdf'),
                  acknowledgeDocumentChanges: true,
                ),
              )
              .toList(),
          throwsA(
            isA<PdfMergeFailure>().having(
              (error) => error.code,
              'code',
              PdfMergeFailureCode.sourceChanged,
            ),
          ),
        );
      });
      test(
        'passwords stay in private job configuration; unlocked sources merge into unencrypted output',
        () async {
          final source = await pdf('plain.pdf', [const PdfColor(1, 0, 0)]);
          final locked = path.join(fixtures.path, 'locked.pdf');
          await runner.run({
            'inputFile': source.path,
            'outputFile': locked,
            'encrypt': {
              'userPassword': 'secret عربي',
              'ownerPassword': 'owner-secret',
              '256bit': {},
            },
          });
          await expectLater(
            repository.inspect(locked),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.passwordRequired,
              ),
            ),
          );
          final document = await repository.inspect(
            locked,
            password: 'secret عربي',
          );
          expect(document.isEncrypted, isTrue);
          final result =
              (await repository
                      .merge(
                        PdfMergeRequest(
                          documents: [document],
                          destinationPath: path.join(
                            fixtures.path,
                            'unlocked.pdf',
                          ),
                          acknowledgeDocumentChanges: true,
                        ),
                      )
                      .toList())
                  .whereType<PdfMergeCompleted>()
                  .single
                  .result;
          expect((await repository.inspect(result.path)).isEncrypted, isFalse);
          final preview = await repository.preview(document, 0);
          expect(
            image_codec.decodePng(File(preview).readAsBytesSync()),
            isNotNull,
          );
        },
      );
      test(
        'interactive forms are rejected before page-only assembly',
        () async {
          final document = pdf_widgets.Document();
          document.addPage(
            pdf_widgets.Page(
              build: (_) => pdf_widgets.Column(
                children: [
                  pdf_widgets.Text('Form'),
                  pdf_widgets.Checkbox(name: 'agreement', value: true),
                ],
              ),
            ),
          );
          final source = File(path.join(fixtures.path, 'form.pdf'));
          await source.writeAsBytes(await document.save());
          await expectLater(
            repository.inspect(source.path),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.unsupportedDocument,
              ),
            ),
          );
        },
      );
      test(
        'restricted user passwords cannot bypass assembly permissions',
        () async {
          final source = await pdf('plain.pdf', [const PdfColor(1, 0, 0)]);
          final locked = path.join(fixtures.path, 'restricted.pdf');
          await runner.run({
            'inputFile': source.path,
            'outputFile': locked,
            'encrypt': {
              'userPassword': 'reader',
              'ownerPassword': 'owner',
              '256bit': {'assemble': 'n'},
            },
          });
          await expectLater(
            repository.inspect(locked, password: 'reader'),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.sourceProtected,
              ),
            ),
          );
          expect(
            (await repository.inspect(locked, password: 'owner')).pageCount,
            1,
          );
        },
      );
      test(
        'overlapping merge streams fail busy without cancelling the owner',
        () async {
          final source = await pdf('source.pdf', [const PdfColor(1, 0, 0)]);
          final document = await repository.inspect(source.path);
          PdfMergeRequest request(String name) => PdfMergeRequest(
            documents: [document],
            destinationPath: path.join(fixtures.path, name),
            acknowledgeDocumentChanges: true,
          );
          final active = repository.merge(request('first.pdf')).toList();
          await expectLater(
            repository.merge(request('second.pdf')).toList(),
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.busy,
              ),
            ),
          );
          expect((await active).whereType<PdfMergeCompleted>(), hasLength(1));
          expect(
            File(path.join(fixtures.path, 'second.pdf')).existsSync(),
            isFalse,
          );
        },
      );
      test(
        'latest preview owns startup and retry; disposal releases cached files',
        () async {
          final source = await pdf('source.pdf', [
            const PdfColor(1, 0, 0),
            const PdfColor(0, 0, 1),
          ]);
          final document = await repository.inspect(source.path);
          final previews = [
            for (final page in [0, 1, 0, 1])
              repository
                  .preview(document, page)
                  .then<Object>(
                    (value) => value,
                    onError: (Object error) => error,
                  ),
          ];
          final results = await Future.wait(previews);
          expect(results.last, isA<String>());
          expect(
            image_codec
                .decodePng(File(results.last as String).readAsBytesSync())!
                .getPixel(0, 0)
                .b,
            greaterThan(240),
          );
          final retry = await repository.preview(document, 0);
          expect(
            image_codec
                .decodePng(File(retry).readAsBytesSync())!
                .getPixel(0, 0)
                .r,
            greaterThan(240),
          );
          expect(await repository.preview(document, 0), retry);
          await repository.dispose();
          expect(File(retry).existsSync(), isFalse);
        },
      );
      test(
        'generated DI shares one session within a page and isolates other pages',
        () async {
          SharedPreferences.setMockInitialValues({});
          final container = GetIt.asNewInstance();
          await container.init();
          await container.unregister<PdfMergeDesktopGateway>();
          container.registerFactory<PdfMergeDesktopGateway>(
            () => TestMergeDesktop(path.join(fixtures.path, 'di-result.pdf')),
          );
          final first = container<PdfMergeBloc>();
          final second = container<PdfMergeBloc>();
          addTearDown(() async {
            if (!first.isClosed) await first.close();
            if (!second.isClosed) await second.close();
            await container.reset();
          });
          final source = await pdf('di-source.pdf', [const PdfColor(1, 0, 0)]);
          Future<PdfMergeState> ready(
            PdfMergeBloc bloc,
            bool Function(PdfMergeState) predicate,
          ) => bloc.stream
              .firstWhere(predicate)
              .timeout(const Duration(seconds: 10));
          first.add(PdfMergeImportRequested([source.path]));
          await ready(
            first,
            (state) => state.documents.isNotEmpty && !state.isBusy,
          );
          expect(second.state.documents, isEmpty);
          second.add(PdfMergeImportRequested([source.path]));
          await ready(
            second,
            (state) => state.documents.isNotEmpty && !state.isBusy,
          );
          await first.close();
          second.add(const PdfMergeAcknowledgementChanged(true));
          await ready(second, (state) => state.canMerge);
          second.add(const PdfMergeRequested('Save'));
          final finished = await ready(
            second,
            (state) => state.result != null || state.failure != null,
          );
          expect(finished.failure, isNull);
          expect(finished.result!.pageCount, 1);
          expect(File(finished.result!.path).existsSync(), isTrue);
        },
      );
      test(
        'large-page preview is capped before raster allocation and creates no duplicate encodings',
        () async {
          final source = await pdf('huge-page.pdf', [
            const PdfColor(0, 0, 1),
          ], pageFormat: const PdfPageFormat(10000, 10000));
          final document = await repository.inspect(source.path);
          final preview = await repository.preview(document, 0);
          final pixels = image_codec.decodePng(
            File(preview).readAsBytesSync(),
          )!;
          expect(pixels.width, 1400);
          expect(pixels.height, 1400);
          expect(File('$preview.preview.png').existsSync(), isFalse);
          expect(File('$preview.thumb.png').existsSync(), isFalse);
        },
      );
      test('invalid input never becomes a fabricated document', () async {
        final source = File(path.join(fixtures.path, 'bad.pdf'))
          ..writeAsStringSync('invalid');
        await expectLater(
          repository.inspect(source.path),
          throwsA(isA<PdfMergeFailure>()),
        );
      });
      test(
        'cancellation during preparation removes staged work and allows retry',
        () async {
          final source = await pdf('source.pdf', [const PdfColor(1, 0, 0)]);
          final document = await repository.inspect(source.path);
          final output = path.join(fixtures.path, 'cancel.pdf');
          final pending = repository
              .merge(
                PdfMergeRequest(
                  documents: [document],
                  destinationPath: output,
                  acknowledgeDocumentChanges: true,
                ),
              )
              .toList();
          await repository.cancel();
          await expectLater(
            pending,
            throwsA(
              isA<PdfMergeFailure>().having(
                (error) => error.code,
                'code',
                PdfMergeFailureCode.cancelled,
              ),
            ),
          );
          expect(File(output).existsSync(), isFalse);
          final result = await repository
              .merge(
                PdfMergeRequest(
                  documents: [document],
                  destinationPath: output,
                  acknowledgeDocumentChanges: true,
                ),
              )
              .toList();
          expect(result.whereType<PdfMergeCompleted>(), hasLength(1));
        },
      );
    },
    skip: runtimeAvailable
        ? false
        : 'Prepare the host QPDF runtime before native tests.',
  );
}
