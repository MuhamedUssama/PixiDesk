import 'dart:io';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/pdf_conversion_failure.dart';
import '../../domain/entities/pdf_to_image_event.dart';
import '../../domain/entities/pdf_to_image_params.dart';
import '../../domain/services/pdf_export_dialogs.dart';
import '../../domain/usecases/cancel_conversion_usecase.dart';
import '../../domain/usecases/convert_pdf_to_images_usecase.dart';
import '../../domain/usecases/release_pdf_conversion_usecase.dart';
import '../../domain/usecases/save_images_usecase.dart';
import '../../domain/usecases/save_as_zip_usecase.dart';
import '../../domain/usecases/save_as_separate_zips_usecase.dart';
import 'pdf_to_image_action.dart';
import 'pdf_to_image_state.dart';

@injectable
class PdfToImageBloc extends Bloc<PdfToImageAction, PdfToImageState> {
  final ConvertPdfToImagesUseCase _convert;
  final SaveImagesUseCase _saveImages;
  final SaveAsZipUseCase _saveArchive;
  final SaveAsSeparateZipsUseCase _saveSeparateArchives;
  final CancelConversionUseCase _cancel;
  final ReleasePdfConversionUseCase _release;
  final PdfExportDialogs _dialogs;
  final Set<String> _ownedJobIds = {};
  String? _activeJobId;
  bool _closing = false;

  PdfToImageBloc(
    this._convert,
    this._saveImages,
    this._saveArchive,
    this._saveSeparateArchives,
    this._cancel,
    this._release,
    this._dialogs,
  ) : super(const PdfToImageState()) {
    on<PdfFilesSelected>((event, emit) {
      if (state.isBusy) return;
      final uniqueFiles = {
        for (final file in [...state.selectedFiles, ...event.files])
          file.absolute.path: file,
      };
      emit(
        state.copyWith(
          selectedFiles: uniqueFiles.values.toList(),
          status: PdfToImageStatus.initial,
          generatedImages: null,
          previewPaths: {},
          thumbnailPaths: {},
          groupedImages: {},
          progress: null,
          failure: null,
          success: null,
          imageRotations: {},
          selectedImagePaths: {},
        ),
      );
    });
    on<PdfFileRemoved>((event, emit) {
      if (!state.isBusy) {
        emit(
          state.copyWith(
            selectedFiles: state.selectedFiles
                .where((file) => file.path != event.path)
                .toList(),
          ),
        );
      }
    });
    on<PdfSettingsChanged>((event, emit) {
      if (!state.isBusy) {
        emit(
          state.copyWith(
            outputFormat: event.format ?? state.outputFormat,
            dpi: event.dpi ?? state.dpi,
          ),
        );
      }
    });
    on<PdfClearRequested>((event, emit) async {
      if (state.isBusy) return;
      emit(const PdfToImageState());
      await _releaseOwnedResults();
    });
    on<PdfConversionRequested>(_onConvert, transformer: droppable());
    on<PdfCancellationRequested>(_onCancel, transformer: droppable());
    on<PdfExportRequested>(_onExport, transformer: droppable());
    on<PdfSelectionToggled>((event, emit) {
      if (state.isBusy ||
          !(state.generatedImages ?? []).any(
            (file) => file.path == event.path,
          )) {
        return;
      }
      final selection = state.selectedImagePaths.toSet();
      if (!selection.add(event.path)) selection.remove(event.path);
      emit(state.copyWith(selectedImagePaths: selection));
    });
    on<PdfPageRotated>((event, emit) {
      if (state.isBusy ||
          !(state.generatedImages ?? []).any(
            (file) => file.path == event.path,
          )) {
        return;
      }
      emit(
        state.copyWith(
          imageRotations: {
            ...state.imageRotations,
            event.path: ((state.imageRotations[event.path] ?? 0) + 1) % 4,
          },
        ),
      );
    });
    on<PdfSelectedPagesDeleted>((event, emit) {
      if (state.isBusy) return;
      final remaining = (state.generatedImages ?? [])
          .where((file) => !state.selectedImagePaths.contains(file.path))
          .toList();
      final paths = remaining.map((file) => file.path).toSet();
      emit(
        state.copyWith(
          generatedImages: remaining.isEmpty ? null : remaining,
          previewPaths: Map.fromEntries(
            state.previewPaths.entries.where(
              (entry) => paths.contains(entry.key),
            ),
          ),
          thumbnailPaths: Map.fromEntries(
            state.thumbnailPaths.entries.where(
              (entry) => paths.contains(entry.key),
            ),
          ),
          status: remaining.isEmpty ? PdfToImageStatus.initial : state.status,
          groupedImages: state.groupedImages.map(
            (source, files) => MapEntry(
              source,
              List<File>.unmodifiable(
                files.where((file) => paths.contains(file.path)),
              ),
            ),
          ),
          imageRotations: Map.fromEntries(
            state.imageRotations.entries.where(
              (entry) => paths.contains(entry.key),
            ),
          ),
          selectedImagePaths: {},
        ),
      );
    });
    on<PdfSelectionCleared>(
      (event, emit) => emit(state.copyWith(selectedImagePaths: {})),
    );
    on<PdfReviewRequested>((event, emit) {
      if (!state.isBusy) {
        emit(
          state.copyWith(
            status: state.generatedImages == null
                ? PdfToImageStatus.initial
                : PdfToImageStatus.review,
            failure: null,
            success: null,
          ),
        );
      }
    });
  }

  Future<void> _onConvert(
    PdfConversionRequested event,
    Emitter<PdfToImageState> emit,
  ) async {
    if (state.isBusy || state.selectedFiles.isEmpty || _closing) return;
    final request = PdfToImageParams(
      jobId: const Uuid().v4(),
      inputPaths: state.selectedFiles.map((file) => file.path).toList(),
      outputFormat: state.outputFormat,
      dpi: state.dpi,
    );
    emit(
      state.copyWith(
        status: PdfToImageStatus.converting,
        progress: null,
        generatedImages: null,
        previewPaths: {},
        thumbnailPaths: {},
        groupedImages: {},
        selectedImagePaths: {},
        imageRotations: {},
        failure: null,
        success: null,
      ),
    );
    try {
      await _releaseOwnedResults();
      if (_closing ||
          emit.isDone ||
          state.status != PdfToImageStatus.converting) {
        return;
      }
      _activeJobId = request.jobId;
      _ownedJobIds.add(request.jobId);
      var completed = false;
      await emit.forEach<PdfToImageEvent>(
        _convert(request),
        onData: (event) {
          if (_closing || state.status != PdfToImageStatus.converting) {
            return state;
          }
          if (event is PdfToImageProgress) {
            return state.copyWith(progress: event.progress);
          }
          if (event is PdfToImageCompleted) {
            if (event.imagePaths.isEmpty) {
              return state.copyWith(
                status: PdfToImageStatus.error,
                failure: PdfConversionFailureCode.workerFailed,
                messageId: state.messageId + 1,
              );
            }
            completed = true;
            return state.copyWith(
              status: PdfToImageStatus.review,
              generatedImages: event.imagePaths.map(File.new).toList(),
              previewPaths: Map.unmodifiable(event.previewPaths),
              thumbnailPaths: Map.unmodifiable(event.thumbnailPaths),
              groupedImages: event.groupedPaths.map(
                (source, paths) => MapEntry(
                  source,
                  List<File>.unmodifiable(paths.map(File.new)),
                ),
              ),
              progress: null,
            );
          }
          return state;
        },
        onError: (error, stack) {
          if (_closing || state.status == PdfToImageStatus.cancelling) {
            return state;
          }
          return state.copyWith(
            status: PdfToImageStatus.error,
            progress: null,
            failure: error is PdfConversionFailure
                ? error.code
                : PdfConversionFailureCode.workerFailed,
            messageId: state.messageId + 1,
          );
        },
      );
      if (!completed &&
          !emit.isDone &&
          !_closing &&
          state.status == PdfToImageStatus.converting) {
        emit(
          state.copyWith(
            status: PdfToImageStatus.error,
            progress: null,
            failure: PdfConversionFailureCode.workerFailed,
            messageId: state.messageId + 1,
          ),
        );
      }
    } catch (error) {
      if (!emit.isDone &&
          !_closing &&
          state.status == PdfToImageStatus.converting) {
        emit(
          state.copyWith(
            status: PdfToImageStatus.error,
            progress: null,
            failure: error is PdfConversionFailure
                ? error.code
                : PdfConversionFailureCode.workerFailed,
            messageId: state.messageId + 1,
          ),
        );
      }
    } finally {
      if (_activeJobId == request.jobId) _activeJobId = null;
    }
  }

  Future<void> _onCancel(
    PdfCancellationRequested event,
    Emitter<PdfToImageState> emit,
  ) async {
    if (state.status != PdfToImageStatus.converting) return;
    emit(state.copyWith(status: PdfToImageStatus.cancelling));
    final jobId = _activeJobId;
    if (jobId != null) await _cancel(jobId);
    if (!emit.isDone && !_closing) {
      emit(
        state.copyWith(
          status: PdfToImageStatus.initial,
          progress: null,
          failure: null,
        ),
      );
    }
  }

  Future<void> _onExport(
    PdfExportRequested event,
    Emitter<PdfToImageState> emit,
  ) async {
    if (state.isBusy || (state.generatedImages?.isEmpty ?? true)) return;
    final snapshot = state;
    emit(
      state.copyWith(
        status: PdfToImageStatus.saving,
        failure: null,
        success: null,
      ),
    );
    try {
      final destination = event.mode == PdfExportMode.archive
          ? await _dialogs.chooseZipPath(event.dialogTitle)
          : await _dialogs.chooseFolder();
      if (_closing || emit.isDone) return;
      if (destination == null) {
        emit(snapshot.copyWith(status: PdfToImageStatus.review));
        return;
      }
      final paths = snapshot.generatedImages!.map((file) => file.path).toList();
      switch (event.mode) {
        case PdfExportMode.folder:
          await _saveImages(paths, destination, snapshot.imageRotations);
        case PdfExportMode.archive:
          await _saveArchive(
            images: paths,
            destinationPath: destination,
            rotations: snapshot.imageRotations,
          );
        case PdfExportMode.separateArchives:
          await _saveSeparateArchives(
            groupedImages: snapshot.groupedImages.map(
              (source, files) =>
                  MapEntry(source, files.map((file) => file.path).toList()),
            ),
            destinationDirectory: destination,
            rotations: snapshot.imageRotations,
          );
      }
      if (!emit.isDone && !_closing) {
        emit(
          state.copyWith(
            status: PdfToImageStatus.review,
            success: PdfExportSuccess.values[event.mode.index],
            messageId: state.messageId + 1,
          ),
        );
      }
    } catch (error) {
      if (!emit.isDone && !_closing) {
        emit(
          state.copyWith(
            status: PdfToImageStatus.review,
            failure: error is PdfConversionFailure
                ? error.code
                : PdfConversionFailureCode.saveFailed,
            messageId: state.messageId + 1,
          ),
        );
      }
    }
  }

  Future<void> _releaseOwnedResults() async {
    final jobs = _ownedJobIds.toList();
    _ownedJobIds.clear();
    for (final jobId in jobs) {
      await _release(jobId);
    }
  }

  // Intent methods preserve the existing view API; all mutations are Bloc events.
  void selectFiles(List<File> files) => add(PdfFilesSelected(files));
  void removeFile(File file) => add(PdfFileRemoved(file.path));
  void updateSettings({String? format, int? dpi}) =>
      add(PdfSettingsChanged(format: format, dpi: dpi));
  void clearFile() => add(const PdfClearRequested());
  void startConversion() => add(const PdfConversionRequested());
  void cancelConversion() => add(const PdfCancellationRequested());
  void toggleImageSelection(String path) => add(PdfSelectionToggled(path));
  void rotateImage(String path) => add(PdfPageRotated(path));
  void deleteSelectedImages() => add(const PdfSelectedPagesDeleted());
  void clearSelection() => add(const PdfSelectionCleared());
  void triggerSaveAll() => add(const PdfExportRequested(PdfExportMode.folder));
  void saveAsSeparateZips() =>
      add(const PdfExportRequested(PdfExportMode.separateArchives));
  void saveAsZip(String dialogTitle) =>
      add(PdfExportRequested(PdfExportMode.archive, dialogTitle: dialogTitle));
  void reset() => add(const PdfReviewRequested());

  @override
  Future<void> close() async {
    _closing = true;
    final jobId = _activeJobId;
    if (jobId != null) await _cancel(jobId);
    await super.close();
    await _releaseOwnedResults();
  }
}
