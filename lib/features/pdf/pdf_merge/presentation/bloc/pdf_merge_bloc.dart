import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pdf_merge_document.dart';
import '../../domain/entities/pdf_merge_event.dart';
import '../../domain/entities/pdf_merge_failure.dart';
import '../../domain/entities/pdf_merge_request.dart';
import '../../domain/services/pdf_merge_desktop_gateway.dart';
import '../../domain/usecases/pdf_merge_usecases.dart';
import 'pdf_merge_action.dart';
import 'pdf_merge_state.dart';

class PdfMergeBloc extends Bloc<PdfMergeAction, PdfMergeState> {
  final InspectPdfForMergeUseCase _inspect;
  final MergePdfsUseCase _merge;
  final PreviewMergePageUseCase _preview;
  final ManagePdfMergeSessionUseCase _session;
  final PdfMergeDesktopGateway _desktop;
  Completer<void>? _activeWorkDone;
  bool _closing = false;

  PdfMergeBloc(
    this._inspect,
    this._merge,
    this._preview,
    this._session,
    this._desktop,
  ) : super(const PdfMergeState()) {
    on<PdfMergePickRequested>((event, emit) async {
      if (!state.canEdit || _closing) return;
      emit(state.copyWith(status: PdfMergeStatus.picking));
      try {
        final paths = await _desktop.selectDocuments();
        if (_closing || emit.isDone) return;
        emit(state.copyWith(status: PdfMergeStatus.initial));
        if (paths.isNotEmpty) add(PdfMergeImportRequested(paths));
      } catch (error) {
        _emitFailure(emit, error);
      }
    }, transformer: droppable());
    on<PdfMergeImportRequested>(_onImport, transformer: droppable());
    on<PdfMergePasswordDismissed>((event, emit) {
      if (state.passwordPath == null) return;
      final remaining = state.pendingImportPaths;
      emit(
        state.copyWith(
          status: PdfMergeStatus.initial,
          passwordPath: null,
          pendingImportPaths: [],
        ),
      );
      if (remaining.isNotEmpty) add(PdfMergeImportRequested(remaining));
    });
    on<PdfMergeDocumentRemoved>((event, emit) async {
      if (!state.canEdit) return;
      emit(
        state.copyWith(
          documents: state.documents
              .where((document) => document.id != event.id)
              .toList(),
          status: PdfMergeStatus.initial,
          result: null,
          previewDocumentId: state.previewDocumentId == event.id
              ? null
              : state.previewDocumentId,
          invalidRangeDocumentIds: state.invalidRangeDocumentIds
              .where((id) => id != event.id)
              .toSet(),
        ),
      );
      await _session.forget(event.id);
    });
    on<PdfMergeDocumentsCleared>((event, emit) async {
      if (!state.canEdit) return;
      final documents = state.documents;
      emit(const PdfMergeState());
      for (final document in documents) {
        await _session.forget(document.id);
      }
    });
    on<PdfMergeDocumentMoved>((event, emit) {
      if (!state.canEdit ||
          event.fromIndex < 0 ||
          event.fromIndex >= state.documents.length) {
        return;
      }
      final documents = state.documents.toList();
      documents.insert(
        event.toIndex.clamp(0, documents.length - 1),
        documents.removeAt(event.fromIndex),
      );
      emit(
        state.copyWith(
          documents: documents,
          status: PdfMergeStatus.initial,
          result: null,
        ),
      );
    });
    on<PdfMergePagesChanged>((event, emit) {
      if (!state.canEdit ||
          !state.documents.any((document) => document.id == event.id)) {
        return;
      }
      final document = state.documents.firstWhere(
        (document) => document.id == event.id,
      );
      if (event.pages.length > 20000 ||
          event.pages.any((page) => page < 0 || page >= document.pageCount)) {
        _emitFailure(
          emit,
          const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange),
        );
        return;
      }
      if (state.totalPages -
              document.selectedPages.length +
              event.pages.length >
          20000) {
        _emitFailure(
          emit,
          const PdfMergeFailure(PdfMergeFailureCode.resourceLimit),
        );
        return;
      }
      _updateDocument(emit, document.copyWith(selectedPages: event.pages));
    });
    on<PdfMergeRangeEdited>((event, emit) {
      if (!state.canEdit) return;
      final document = state.documents
          .where((document) => document.id == event.id)
          .firstOrNull;
      if (document == null) return;
      try {
        final pages = parsePdfPageRange(event.text, document.pageCount);
        if (state.totalPages - document.selectedPages.length + pages.length >
            20000) {
          throw const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange);
        }
        final errors = state.invalidRangeDocumentIds.toSet()..remove(event.id);
        emit(
          state.copyWith(
            invalidRangeDocumentIds: errors,
            documents: state.documents
                .map(
                  (item) => item.id == event.id
                      ? item.copyWith(selectedPages: pages)
                      : item,
                )
                .toList(),
            status: PdfMergeStatus.initial,
            result: null,
          ),
        );
      } on PdfMergeFailure {
        emit(
          state.copyWith(
            invalidRangeDocumentIds: {
              ...state.invalidRangeDocumentIds,
              event.id,
            },
            result: null,
          ),
        );
      }
    });
    on<PdfMergePageRotated>((event, emit) {
      if (!state.canEdit) return;
      final document = state.documents
          .where((document) => document.id == event.id)
          .firstOrNull;
      if (document == null) return;
      final pages = event.pageIndex == null
          ? document.selectedPages.toSet()
          : {event.pageIndex!};
      if (pages.any((page) => page < 0 || page >= document.pageCount)) return;
      final rotations = {...document.rotations};
      for (final page in pages) {
        rotations[page] = ((rotations[page] ?? 0) + 1) % 4;
      }
      _updateDocument(emit, document.copyWith(rotations: rotations));
    });
    on<PdfMergeAcknowledgementChanged>((event, emit) {
      if (state.canEdit) {
        emit(state.copyWith(acknowledgeDocumentChanges: event.value));
      }
    });
    on<PdfMergeRequested>(_onMerge, transformer: droppable());
    on<PdfMergeCancelRequested>(_onCancel, transformer: droppable());
    on<PdfMergePreviewRequested>(_onPreview, transformer: restartable());
    on<PdfMergePreviewClosed>(
      (event, emit) => emit(
        state.copyWith(
          previewDocumentId: null,
          previewPath: null,
          previewFailure: null,
          isPreviewLoading: false,
        ),
      ),
    );
    on<PdfMergeOutputOpened>((event, emit) async {
      final result = state.result;
      if (result == null || state.isBusy) return;
      try {
        if (event.reveal) {
          await _desktop.revealDocument(result.path);
        } else {
          await _desktop.openDocument(result.path);
        }
      } catch (error) {
        _emitFailure(emit, error);
      }
    }, transformer: droppable());
  }

  Future<void> _onImport(
    PdfMergeImportRequested event,
    Emitter<PdfMergeState> emit,
  ) async {
    if (_closing ||
        state.isBusy ||
        event.paths.isEmpty ||
        (state.passwordPath != null &&
            state.passwordPath != event.paths.first)) {
      return;
    }
    if (event.paths.length + state.documents.length > 100) {
      _emitFailure(
        emit,
        const PdfMergeFailure(PdfMergeFailureCode.resourceLimit),
      );
      return;
    }
    final done = _activeWorkDone = Completer<void>();
    emit(
      state.copyWith(
        status: PdfMergeStatus.importing,
        passwordPath: null,
        pendingImportPaths: [],
        failure: null,
        result: null,
      ),
    );
    try {
      for (var index = 0; index < event.paths.length; index++) {
        if (_closing ||
            state.status == PdfMergeStatus.cancelling ||
            emit.isDone) {
          return;
        }
        try {
          final document = await _inspect(
            event.paths[index],
            password: index == 0 ? event.password : null,
          );
          if (_closing ||
              state.status == PdfMergeStatus.cancelling ||
              emit.isDone) {
            await _session.forget(document.id);
            return;
          }
          if (state.documents.any(
            (existing) => existing.path == document.path,
          )) {
            await _session.forget(document.id);
            continue;
          }
          if (state.totalPages + document.pageCount > 20000 ||
              state.totalBytes + document.sizeBytes > 4 * 1024 * 1024 * 1024) {
            await _session.forget(document.id);
            throw const PdfMergeFailure(PdfMergeFailureCode.resourceLimit);
          }
          emit(state.copyWith(documents: [...state.documents, document]));
        } catch (error) {
          if (_closing ||
              state.status == PdfMergeStatus.cancelling ||
              emit.isDone) {
            return;
          }
          if (error is PdfMergeFailure &&
              error.code == PdfMergeFailureCode.passwordRequired) {
            emit(
              state.copyWith(
                status: PdfMergeStatus.awaitingPassword,
                passwordPath: event.paths[index],
                failure: event.password != null
                    ? PdfMergeFailureCode.passwordRequired
                    : null,
                pendingImportPaths: event.paths.skip(index + 1).toList(),
              ),
            );
            return;
          }
          _emitFailure(emit, error, retainStatus: true);
        }
      }
    } finally {
      if (!_closing &&
          !emit.isDone &&
          state.status == PdfMergeStatus.importing) {
        emit(state.copyWith(status: PdfMergeStatus.initial));
      }
      done.complete();
      if (identical(_activeWorkDone, done)) _activeWorkDone = null;
    }
  }

  Future<void> _onMerge(
    PdfMergeRequested event,
    Emitter<PdfMergeState> emit,
  ) async {
    if (_closing || !state.canMerge) return;
    final snapshot = state;
    emit(state.copyWith(status: PdfMergeStatus.picking, failure: null));
    final done = _activeWorkDone = Completer<void>();
    try {
      final destination = await _desktop.selectDestination(event.dialogTitle);
      if (_closing || emit.isDone) return;
      if (destination == null) {
        emit(state.copyWith(status: PdfMergeStatus.initial));
        return;
      }
      emit(
        state.copyWith(
          status: PdfMergeStatus.merging,
          stage: PdfMergeStage.preparing,
          progress: null,
          result: null,
          previewDocumentId: null,
          previewPath: null,
        ),
      );
      var completed = false;
      await emit.forEach<PdfMergeEvent>(
        _merge(
          PdfMergeRequest(
            documents: snapshot.documents,
            destinationPath: destination,
            acknowledgeDocumentChanges: snapshot.acknowledgeDocumentChanges,
          ),
        ),
        onData: (event) {
          if (_closing) return state;
          if (event is PdfMergeCompleted) {
            completed = true;
            return state.copyWith(
              status: PdfMergeStatus.completed,
              result: event.result,
              stage: null,
              progress: null,
            );
          }
          if (event is PdfMergeProgress &&
              state.status != PdfMergeStatus.cancelling) {
            return state.copyWith(stage: event.stage, progress: event.fraction);
          }
          return state;
        },
        onError: (error, stack) {
          if (_closing ||
              state.status == PdfMergeStatus.cancelling ||
              (error is PdfMergeFailure &&
                  error.code == PdfMergeFailureCode.cancelled)) {
            return state;
          }
          return state.copyWith(
            status: PdfMergeStatus.initial,
            stage: null,
            progress: null,
            failure: _failureCode(error),
            messageId: state.messageId + 1,
          );
        },
      );
      if (!completed &&
          !_closing &&
          !emit.isDone &&
          state.status == PdfMergeStatus.merging) {
        _emitFailure(
          emit,
          const PdfMergeFailure(PdfMergeFailureCode.mergeFailed),
        );
      }
    } catch (error) {
      _emitFailure(emit, error);
    } finally {
      done.complete();
      if (identical(_activeWorkDone, done)) _activeWorkDone = null;
    }
  }

  Future<void> _onCancel(
    PdfMergeCancelRequested event,
    Emitter<PdfMergeState> emit,
  ) async {
    if (state.status != PdfMergeStatus.merging &&
        state.status != PdfMergeStatus.importing) {
      return;
    }
    final done = _activeWorkDone;
    emit(state.copyWith(status: PdfMergeStatus.cancelling));
    await _session.cancel();
    await done?.future;
    if (!_closing &&
        !emit.isDone &&
        state.status == PdfMergeStatus.cancelling) {
      emit(
        state.copyWith(
          status: PdfMergeStatus.initial,
          stage: null,
          progress: null,
        ),
      );
    }
  }

  Future<void> _onPreview(
    PdfMergePreviewRequested event,
    Emitter<PdfMergeState> emit,
  ) async {
    final document = state.documents
        .where((document) => document.id == event.id)
        .firstOrNull;
    if (!state.canEdit ||
        document == null ||
        event.pageIndex < 0 ||
        event.pageIndex >= document.pageCount) {
      return;
    }
    emit(
      state.copyWith(
        previewDocumentId: event.id,
        previewPageIndex: event.pageIndex,
        previewPath: null,
        previewFailure: null,
        isPreviewLoading: true,
      ),
    );
    try {
      final preview = await _preview(document, event.pageIndex);
      if (!_closing &&
          !emit.isDone &&
          state.previewDocumentId == event.id &&
          state.previewPageIndex == event.pageIndex) {
        emit(state.copyWith(previewPath: preview, isPreviewLoading: false));
      }
    } catch (error) {
      if (!_closing &&
          !emit.isDone &&
          state.previewDocumentId == event.id &&
          state.previewPageIndex == event.pageIndex) {
        emit(
          state.copyWith(
            isPreviewLoading: false,
            previewFailure: PdfMergeFailureCode.previewUnavailable,
          ),
        );
      }
    }
  }

  void _updateDocument(Emitter<PdfMergeState> emit, PdfMergeDocument updated) =>
      emit(
        state.copyWith(
          documents: state.documents
              .map((document) => document.id == updated.id ? updated : document)
              .toList(),
          status: PdfMergeStatus.initial,
          result: null,
        ),
      );
  PdfMergeFailureCode _failureCode(Object error) =>
      error is PdfMergeFailure ? error.code : PdfMergeFailureCode.mergeFailed;
  void _emitFailure(
    Emitter<PdfMergeState> emit,
    Object error, {
    bool retainStatus = false,
  }) {
    if (_closing || emit.isDone) return;
    emit(
      state.copyWith(
        status: retainStatus ? state.status : PdfMergeStatus.initial,
        stage: null,
        progress: null,
        failure: _failureCode(error),
        messageId: state.messageId + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    _closing = true;
    await _session.cancel();
    await super.close();
    await _session.dispose();
  }
}
