import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_document.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_request.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_event.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_failure.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/repositories/pdf_merge_repository.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/services/pdf_merge_desktop_gateway.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/usecases/pdf_merge_usecases.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_action.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_state.dart';

class RepositoryMock extends Mock implements PdfMergeRepository {}

class DesktopMock extends Mock implements PdfMergeDesktopGateway {}

PdfMergeDocument document(String id, String path) => PdfMergeDocument(
  id: id,
  path: path,
  displayName: path,
  pageCount: 3,
  sizeBytes: 100,
  modifiedMicroseconds: 1,
  changedMicroseconds: 1,
  selectedPages: [0, 1, 2],
);
Future<void> settleEvents() =>
    Future<void>.delayed(const Duration(milliseconds: 20));
void main() {
  late RepositoryMock repository;
  late DesktopMock desktop;
  late PdfMergeBloc bloc;
  late StreamController<PdfMergeEvent> merging;
  setUpAll(() {
    registerFallbackValue(
      PdfMergeRequest(
        documents: [],
        destinationPath: '/fallback.pdf',
        acknowledgeDocumentChanges: true,
      ),
    );
    registerFallbackValue(document('fallback', '/fallback.pdf'));
  });

  setUp(() {
    repository = RepositoryMock();
    desktop = DesktopMock();
    merging = StreamController<PdfMergeEvent>();
    when(
      () => repository.inspect(any(), password: any(named: 'password')),
    ).thenAnswer(
      (request) async => document(
        request.positionalArguments.single as String,
        request.positionalArguments.single as String,
      ),
    );
    when(() => repository.forget(any())).thenAnswer((_) async {});
    when(() => repository.cancel()).thenAnswer((_) async {
      if (merging.hasListener) await merging.close();
    });
    when(() => repository.dispose()).thenAnswer((_) async {});
    when(() => repository.merge(any())).thenAnswer((_) => merging.stream);
    when(
      () => desktop.selectDestination(any()),
    ).thenAnswer((_) async => '/output.pdf');
    bloc = PdfMergeBloc(
      InspectPdfForMergeUseCase(repository),
      MergePdfsUseCase(repository),
      PreviewMergePageUseCase(repository),
      ManagePdfMergeSessionUseCase(repository),
      desktop,
    );
  });
  tearDown(() async {
    await bloc.close();
    if (!merging.isClosed) {
      if (!merging.hasListener) unawaited(merging.stream.drain<void>());
      await merging.close();
    }
  });
  Future<void> import() async {
    bloc.add(PdfMergeImportRequested(['/a.pdf', '/b.pdf']));
    await settleEvents();
  }

  test(
    'document/page order, immutable selection, and invalid range block merging',
    () async {
      await import();
      bloc.add(const PdfMergeDocumentMoved(1, 0));
      await settleEvents();
      expect(bloc.state.documents.first.id, '/b.pdf');
      bloc.add(const PdfMergeRangeEdited('/b.pdf', '3,1-2'));
      bloc.add(const PdfMergeAcknowledgementChanged(true));
      await settleEvents();
      expect(bloc.state.documents.first.selectedPages, [2, 0, 1]);
      expect(bloc.state.canMerge, isTrue);
      expect(
        () => bloc.state.documents.first.selectedPages.add(4),
        throwsUnsupportedError,
      );
      bloc.add(const PdfMergeRangeEdited('/b.pdf', '999'));
      await settleEvents();
      expect(bloc.state.canMerge, isFalse);
      expect(bloc.state.invalidRangeDocumentIds, contains('/b.pdf'));
      bloc.add(const PdfMergeRangeEdited('/b.pdf', '2'));
      await settleEvents();
      expect(bloc.state.canMerge, isTrue);
    },
  );
  test(
    'merge snapshots input and drops duplicate clicks; cancellation reaches the backend',
    () async {
      await import();
      bloc.add(const PdfMergeAcknowledgementChanged(true));
      await settleEvents();
      bloc.add(const PdfMergeRequested('Save'));
      await settleEvents();
      bloc.add(const PdfMergeRequested('Save'));
      bloc.add(const PdfMergeDocumentRemoved('/a.pdf'));
      await settleEvents();
      verify(() => repository.merge(any())).called(1);
      expect(bloc.state.documents, hasLength(2));
      bloc.add(const PdfMergeCancelRequested());
      await settleEvents();
      expect(bloc.state.status, PdfMergeStatus.initial);
      verify(() => repository.cancel()).called(1);
    },
  );
  test('late save picker does not start merge after closing', () async {
    await import();
    bloc.add(const PdfMergeAcknowledgementChanged(true));
    await settleEvents();
    final picker = Completer<String?>();
    when(
      () => desktop.selectDestination(any()),
    ).thenAnswer((_) => picker.future);
    bloc.add(const PdfMergeRequested('Save'));
    await settleEvents();
    final closing = bloc.close();
    picker.complete('/output.pdf');
    await closing;
    verifyNever(() => repository.merge(any()));
  });
  test(
    'password requests retain remaining imports without storing credentials in state',
    () async {
      when(
        () => repository.inspect('/a.pdf', password: null),
      ).thenThrow(const PdfMergeFailure(PdfMergeFailureCode.passwordRequired));
      await import();
      expect(bloc.state.passwordPath, '/a.pdf');
      expect(bloc.state.pendingImportPaths, ['/b.pdf']);
      bloc.add(
        PdfMergeImportRequested(['/a.pdf', '/b.pdf'], password: 'secret'),
      );
      await settleEvents();
      expect(bloc.state.documents, hasLength(2));
      expect(bloc.state.passwordPath, isNull);
      expect(bloc.state.toString(), isNot(contains('secret')));
    },
  );
  test('new preview wins when old rendering completes later', () async {
    await import();
    final first = Completer<String>();
    final second = Completer<String>();
    when(() => repository.preview(any(), 0)).thenAnswer((_) => first.future);
    when(() => repository.preview(any(), 1)).thenAnswer((_) => second.future);
    bloc.add(const PdfMergePreviewRequested('/a.pdf', 0));
    await settleEvents();
    bloc.add(const PdfMergePreviewRequested('/a.pdf', 1));
    await settleEvents();
    second.complete('/second.png');
    await settleEvents();
    first.complete('/first.png');
    await settleEvents();
    expect(bloc.state.previewPageIndex, 1);
    expect(bloc.state.previewPath, '/second.png');
  });
  test('completion remains visible with accurate output details', () async {
    await import();
    bloc.add(const PdfMergeAcknowledgementChanged(true));
    await settleEvents();
    bloc.add(const PdfMergeRequested('Save'));
    await settleEvents();
    merging.add(
      const PdfMergeCompleted(
        PdfMergeResult(path: '/output.pdf', pageCount: 6, sizeBytes: 1024),
      ),
    );
    await merging.close();
    await settleEvents();
    expect(bloc.state.status, PdfMergeStatus.completed);
    expect(bloc.state.result!.pageCount, 6);
    expect(bloc.state.progress, isNull);
  });
}
