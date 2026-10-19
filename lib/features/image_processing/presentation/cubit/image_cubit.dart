import '../../domain/entities/image_geometry.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_output_name.dart';
import '../../domain/entities/image_recipe.dart';
import '../../domain/usecases/process_image_usecase.dart';
import '../../domain/usecases/compress_image_usecase.dart';
import '../../domain/usecases/convert_image_usecase.dart';
import '../../domain/usecases/preview_image_usecase.dart';
import '../../domain/usecases/image_desktop_usecase.dart';
import '../../domain/usecases/image_workspace_usecase.dart';
import 'image_state.dart';

@injectable
class ImageCubit extends Cubit<ImageState> {
  final ProcessImageUseCase _process;
  final ConvertImageUseCase _convert;
  final CompressImageUseCase _compress;
  final PreviewImageUseCase _preview;
  final ImageDesktopUseCase _desktop;
  final ImageWorkspaceUseCase _workspace;
  ImageCancellation? _token;
  Completer<void>? _resume;
  StreamSubscription<String>? _watch;
  final _watchPending = <String>[];
  ImageRecipe? _watchRecipe;
  String? _watchOutput;
  final _undo = <ImageRecipe>[];
  final _redo = <ImageRecipe>[];
  bool _loaded = false;
  Future<void>? _initialization;
  bool _loadFailed = false;

  ImageCubit(
    this._process,
    this._convert,
    this._compress,
    this._preview,
    this._desktop,
    this._workspace,
  ) : super(const ImageState());

  void _emit(ImageState value) {
    if (!isClosed) emit(value);
  }

  void _error(Object error) => _emit(
    state.copyWith(
      failure: error is ImageFailure
          ? error.code
          : ImageFailureCode.encodeFailed,
      messageId: state.messageId + 1,
    ),
  );
  ImageCancellation _begin(ImageOperation operation) {
    final token = ImageCancellation();
    _token = token;
    _emit(state.copyWith(operation: operation, clearFailure: true));
    return token;
  }

  void _end(ImageCancellation token) {
    if (identical(token, _token)) {
      _token = null;
      _emit(state.copyWith(operation: ImageOperation.idle, paused: false));
      if (_watchPending.isNotEmpty) scheduleMicrotask(_drainWatch);
    }
  }

  Future<void> initialize() => _initialization ??= _loadWorkspace();
  Future<void> _loadWorkspace() async {
    final token = _begin(ImageOperation.importing);
    try {
      final workspace = await _workspace.load();
      token.check();
      _emit(
        state.copyWith(
          presets: workspace.presets,
          history: workspace.history,
          recovery: workspace.recovery,
        ),
      );
    } catch (e) {
      _loadFailed = true;
      if (!token.isCancelled) _error(e);
    } finally {
      _loaded = true;
      _end(token);
    }
  }

  Future<void> _persist() async {
    // Do not overwrite an unreadable workspace with a partial default snapshot.
    if (_loadFailed || !_loaded) return;
    try {
      await _workspace.save(
        ImageWorkspace(
          presets: state.presets,
          history: state.history,
          recovery: state.recovery,
        ),
      );
    } catch (e) {
      _error(e);
    }
  }

  Future<void> pickImages(String title) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      final paths = await _desktop.pickImages(title);
      token.check();
      await _inspect(paths, token);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> addImages(List<String> paths) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      await _inspect(paths, token);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> _inspect(List<String> paths, ImageCancellation token) async {
    final incoming = paths.toSet().take(1000);
    for (final path in incoming) {
      token.check();
      if (state.jobs.length >= 1000) {
        throw const ImageFailure(ImageFailureCode.resourceLimit);
      }
      try {
        final source = await _process.inspect(path, token);
        token.check();
        final existing = state.jobs.indexWhere(
          (j) => j.source.path == source.path,
        );
        if (existing >= 0) {
          if (state.jobs[existing].source != source) {
            final jobs = [...state.jobs];
            jobs[existing] = ImageJob(source: source);
            _emit(
              state.copyWith(
                jobs: jobs,
                selectedIndex: existing,
                clearPreview: true,
              ),
            );
          }
          continue;
        }
        _emit(
          state.copyWith(
            jobs: [
              ...state.jobs,
              ImageJob(source: source),
            ],
            selectedIndex: state.jobs.length,
            clearPreview: true,
            clearText: true,
          ),
        );
      } on ImageFailure catch (e) {
        if (e.code == ImageFailureCode.cancelled) rethrow;
        _error(e);
      }
    }
  }

  Future<void> addFolder(String title, {bool recursive = false}) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      final folder = await _desktop.pickFolder(title);
      token.check();
      if (folder != null) {
        await _inspect(
          await _workspace.listImages(folder, recursive: recursive),
          token,
        );
      }
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> pasteImages() async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      final paths = await _desktop.pasteImages();
      token.check();
      if (paths.isEmpty) {
        throw const ImageFailure(ImageFailureCode.invalidInput);
      }
      await _inspect(paths, token);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  void selectImage(int index) {
    if (state.busy || index < 0 || index >= state.jobs.length) return;
    _emit(
      state.copyWith(
        selectedIndex: index,
        clearPreview: true,
        clearText: true,
        clearFailure: true,
      ),
    );
  }

  void removeSelected() {
    if (state.busy || state.selectedImage == null) return;
    final jobs = [...state.jobs]..removeAt(state.selectedIndex);
    _emit(
      state.copyWith(
        jobs: jobs,
        selectedIndex: state.selectedIndex.clamp(
          0,
          jobs.isEmpty ? 0 : jobs.length - 1,
        ),
        clearPreview: true,
        clearText: true,
      ),
    );
  }

  void clearQueue() {
    if (!state.busy) {
      _emit(
        state.copyWith(
          jobs: [],
          selectedIndex: 0,
          clearPreview: true,
          clearText: true,
        ),
      );
    }
  }

  void updateRecipe(ImageRecipe recipe, {bool record = true}) {
    if (state.busy || recipe == state.recipe) return;
    try {
      recipe.validate();
      if (record) {
        _undo.add(state.recipe);
        if (_undo.length > 50) _undo.removeAt(0);
        _redo.clear();
      }
      _emit(
        state.copyWith(
          recipe: recipe,
          clearPreview: true,
          clearFailure: true,
          canUndo: _undo.isNotEmpty,
          canRedo: _redo.isNotEmpty,
        ),
      );
    } catch (e) {
      _error(e);
    }
  }

  void undo() {
    if (state.busy || _undo.isEmpty) return;
    _redo.add(state.recipe);
    _emit(
      state.copyWith(
        recipe: _undo.removeLast(),
        canUndo: _undo.isNotEmpty,
        canRedo: true,
        clearPreview: true,
      ),
    );
  }

  void redo() {
    if (state.busy || _redo.isEmpty) return;
    _undo.add(state.recipe);
    _emit(
      state.copyWith(
        recipe: _redo.removeLast(),
        canUndo: true,
        canRedo: _redo.isNotEmpty,
        clearPreview: true,
      ),
    );
  }

  Future<void> chooseWatermark(String title) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      final paths = await _desktop.pickImages(title);
      token.check();
      if (paths.isNotEmpty) {
        final image = await _process.inspect(paths.first, token);
        token.check();
        final recipe = state.recipe.copyWith(watermarkPath: image.path);
        _end(token);
        updateRecipe(recipe);
      }
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> exportAssetScales(String title) async {
    final source = state.selectedImage;
    if (state.busy || source == null) return;
    final recipe = state.recipe;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final scales = ImageGeometry.assetScales(source, recipe);
      final folder = await _desktop.pickFolder(title);
      token.check();
      if (folder == null) return;
      _emit(
        state.copyWith(
          operation: ImageOperation.exporting,
          total: 3,
          finished: 0,
        ),
      );
      for (var scale = 1; scale <= 3; scale++) {
        token.check();
        final r = scales[scale - 1];
        final name = ImageOutputName.build(
          '{name}_${scale}x',
          source,
          r,
          scale - 1,
        );
        await _runOne(source, r, p.join(folder, name), token);
        _emit(state.copyWith(finished: scale));
      }
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> preview() async {
    final source = state.selectedImage;
    if (state.busy || source == null) return;
    final recipe = state.recipe;
    final token = _begin(ImageOperation.previewing);
    try {
      final bytes = await _preview(source, recipe, token);
      token.check();
      _emit(state.copyWith(preview: bytes));
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  void setNamingPattern(String value) {
    if (!state.busy) _emit(state.copyWith(namingPattern: value));
  }

  void setConflict(OutputConflict conflict) {
    if (!state.busy) _emit(state.copyWith(conflict: conflict));
  }

  Future<void> chooseOutputFolder(String title) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final path = await _desktop.pickFolder(title);
      token.check();
      if (path != null) _emit(state.copyWith(outputFolder: path));
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> exportImage(String title, {bool compress = false}) async {
    final source = state.selectedImage;
    if (state.busy || source == null) return;
    final recipe =
        compress && ImageFormat.outputFormats.contains(source.format.canonical)
        ? state.recipe.copyWith(
            format: source.format.canonical,
            clearTarget:
                !source.format.supportsQuality ||
                (source.format == ImageFormat.webp &&
                    state.recipe.webpLossless),
          )
        : state.recipe;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final name = ImageOutputName.build(
        state.namingPattern,
        source,
        recipe,
        state.selectedIndex,
      );
      final path = await _desktop.savePath(title, name, [
        recipe.format.extension,
      ]);
      token.check();
      if (path == null) return;
      final ext = p.extension(path).toLowerCase();
      final normalized =
          ImageFormat.fromPath(path).canonical == recipe.format.canonical
          ? path
          : '${ext.isEmpty ? path : p.withoutExtension(path)}.${recipe.format.extension}';
      _emit(
        state.copyWith(
          operation: ImageOperation.exporting,
          total: 1,
          finished: 0,
        ),
      );
      // If normalization changed the selected path, never replace an unconfirmed file.
      final conflict = normalized == path
          ? state.conflict
          : OutputConflict.rename;
      await _runOne(
        source,
        recipe,
        normalized,
        token,
        compress: compress,
        conflict: conflict,
      );
      token.check();
      _emit(state.copyWith(finished: 1));
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> exportBatch(String title, {bool failedOnly = false}) async {
    if (state.busy || state.jobs.isEmpty) return;
    final sources = state.jobs
        .where(
          (j) =>
              !failedOnly ||
              j.status == ImageJobStatus.failed ||
              j.status == ImageJobStatus.cancelled,
        )
        .map((j) => j.source)
        .toList(growable: false);
    if (sources.isEmpty) return;
    final recipe = state.recipe,
        pattern = state.namingPattern,
        conflict = state.conflict;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final folder = state.outputFolder ?? await _desktop.pickFolder(title);
      token.check();
      if (folder == null) return;
      _emit(
        state.copyWith(
          outputFolder: folder,
          operation: ImageOperation.exporting,
          finished: 0,
          total: sources.length,
        ),
      );
      final planned = [...state.recovery];
      for (var index = 0; index < sources.length; index++) {
        final path = p.join(
          folder,
          ImageOutputName.build(pattern, sources[index], recipe, index),
        );
        final entry = _plannedEntry(sources[index], recipe, path);
        if (!planned.any((e) => e.id == entry.id)) {
          planned.add(entry);
        }
      }
      _emit(state.copyWith(recovery: planned.take(1000).toList()));
      await _persist();
      for (var index = 0; index < sources.length; index++) {
        token.check();
        if (state.paused) {
          _resume = Completer<void>();
          await Future.any([_resume!.future, token.whenCancelled]);
          token.check();
        }
        final source = sources[index];
        try {
          final name = ImageOutputName.build(pattern, source, recipe, index);
          await _runOne(
            source,
            recipe,
            p.join(folder, name),
            token,
            conflict: conflict,
          );
        } on ImageFailure catch (e) {
          if (e.code == ImageFailureCode.cancelled) rethrow;
          _error(e);
        }
        _emit(state.copyWith(finished: index + 1));
      }
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      if (token.isCancelled) {
        final paths = sources.map((s) => s.path).toSet();
        _emit(
          state.copyWith(
            jobs: state.jobs
                .map(
                  (j) =>
                      paths.contains(j.source.path) &&
                          (j.status == ImageJobStatus.pending ||
                              j.status == ImageJobStatus.running)
                      ? j.copyWith(
                          status: ImageJobStatus.cancelled,
                          failure: ImageFailureCode.cancelled,
                        )
                      : j,
                )
                .toList(),
          ),
        );
      }
      _resume = null;
      _end(token);
    }
  }

  void _updateJob(String path, ImageJob Function(ImageJob) update) => _emit(
    state.copyWith(
      jobs: state.jobs
          .map((j) => j.source.path == path ? update(j) : j)
          .toList(),
    ),
  );
  ImageHistoryEntry _plannedEntry(
    ImageEntity source,
    ImageRecipe recipe,
    String path,
  ) =>
      state.recovery
          .where(
            (e) =>
                e.sourcePath == source.path &&
                e.outputPath == path &&
                e.recipe == recipe,
          )
          .firstOrNull ??
      ImageHistoryEntry(
        id: const Uuid().v4(),
        sourcePath: source.path,
        outputPath: path,
        sourceBytes: source.sizeInBytes,
        sourceModifiedMicros: source.modifiedMicros,
        outputBytes: 0,
        createdAt: DateTime.now(),
        recipe: recipe,
      );

  Future<void> _runOne(
    ImageEntity source,
    ImageRecipe recipe,
    String path,
    ImageCancellation token, {
    bool compress = false,
    OutputConflict conflict = OutputConflict.rename,
  }) async {
    final journal = _plannedEntry(source, recipe, path);
    if (!state.recovery.any((e) => e.id == journal.id)) {
      _emit(
        state.copyWith(
          recovery: [...state.recovery, journal].take(1000).toList(),
        ),
      );
      await _persist();
    }
    token.check();
    _updateJob(
      source.path,
      (j) => j.copyWith(status: ImageJobStatus.running, reset: true),
    );
    try {
      final request = ImageRequest(
        source: source,
        recipe: recipe,
        destinationPath: path,
        protectedPaths: List.unmodifiable(state.jobs.map((j) => j.source.path)),
        conflict: conflict,
      );
      final result = await (compress
          ? _compress(request, token)
          : _convert(request, token));
      // A successful return means commit already happened. Later cancellation affects the next item.
      _updateJob(
        source.path,
        (j) => j.copyWith(
          status: result.skipped
              ? ImageJobStatus.skipped
              : ImageJobStatus.completed,
          result: result,
        ),
      );
      final remaining = state.recovery
          .where((e) => e.id != journal.id)
          .toList();
      if (!result.skipped && !isClosed) {
        final entry = ImageHistoryEntry(
          id: journal.id,
          sourcePath: source.path,
          outputPath: result.path,
          sourceBytes: source.sizeInBytes,
          sourceModifiedMicros: source.modifiedMicros,
          outputBytes: result.outputBytes,
          createdAt: DateTime.now(),
          recipe: recipe,
        );
        _emit(
          state.copyWith(
            history: [entry, ...state.history].take(200).toList(),
            recovery: remaining,
          ),
        );
      } else {
        _emit(state.copyWith(recovery: remaining));
      }
      await _persist();
    } on ImageFailure catch (e) {
      _updateJob(
        source.path,
        (j) => j.copyWith(
          status: e.code == ImageFailureCode.cancelled
              ? ImageJobStatus.cancelled
              : ImageJobStatus.failed,
          failure: e.code,
        ),
      );
      rethrow;
    }
  }

  void togglePause() {
    if (state.operation != ImageOperation.exporting) return;
    final pause = !state.paused;
    _emit(state.copyWith(paused: pause));
    if (!pause && _resume != null && !_resume!.isCompleted) _resume!.complete();
  }

  void cancel() {
    _token?.cancel();
    if (_resume != null && !_resume!.isCompleted) _resume!.complete();
  }

  Future<void> savePreset(String name, {ImageRecipe? recipe}) async {
    if (state.busy ||
        name.trim().isEmpty ||
        name.length > 80 ||
        state.presets.length >= 50) {
      return;
    }
    await initialize();
    final preset = ImagePreset(
      id: const Uuid().v4(),
      name: name.trim(),
      recipe: recipe ?? state.recipe,
    );
    _emit(state.copyWith(presets: [...state.presets, preset]));
    await _persist();
  }

  Future<void> renamePreset(String id, String name) async {
    if (state.busy || name.trim().isEmpty || name.length > 80) return;
    _emit(
      state.copyWith(
        presets: state.presets
            .map(
              (p) => p.id == id
                  ? ImagePreset(id: id, name: name.trim(), recipe: p.recipe)
                  : p,
            )
            .toList(),
      ),
    );
    await _persist();
  }

  Future<void> deletePreset(String id) async {
    if (state.busy) return;
    _emit(
      state.copyWith(presets: state.presets.where((p) => p.id != id).toList()),
    );
    await _persist();
  }

  Future<void> importPreset(String title) async {
    if (state.busy) return;
    await initialize();
    final token = _begin(ImageOperation.importing);
    try {
      final text = await _desktop.readPreset(title);
      token.check();
      if (text == null) return;
      if (state.presets.length >= 50) {
        throw const ImageFailure(ImageFailureCode.resourceLimit);
      }
      final preset = await _workspace.decodePreset(text);
      token.check();
      _emit(
        state.copyWith(
          presets: [
            ...state.presets,
            ImagePreset(
              id: const Uuid().v4(),
              name: preset.name,
              recipe: preset.recipe,
            ),
          ],
        ),
      );
      await _persist();
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> exportPreset(String title, ImagePreset preset) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final text = await _workspace.encodePreset(preset);
      token.check();
      await _desktop.writeText(title, 'preset.json', text);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> clearHistory() async {
    if (!state.busy) {
      _emit(state.copyWith(history: [], recovery: []));
      await _persist();
    }
  }

  Future<void> restoreHistory(ImageHistoryEntry entry) async {
    if (state.busy) return;
    final token = _begin(ImageOperation.importing);
    try {
      final source = await _process.inspect(entry.sourcePath, token);
      token.check();
      if (source.sizeInBytes != entry.sourceBytes ||
          source.modifiedMicros != entry.sourceModifiedMicros) {
        throw const ImageFailure(ImageFailureCode.sourceChanged);
      }
      final exists = state.jobs.indexWhere((j) => j.source.path == source.path);
      _emit(
        state.copyWith(
          jobs: exists >= 0
              ? state.jobs
              : [...state.jobs, ImageJob(source: source)],
          selectedIndex: exists >= 0 ? exists : state.jobs.length,
          recipe: entry.recipe,
          recovery: state.recovery.where((e) => e.id != entry.id).toList(),
          clearPreview: true,
        ),
      );
      await _persist();
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> openFile(String path, {bool reveal = false}) async {
    try {
      await _desktop.openFile(path, reveal: reveal);
    } catch (e) {
      _error(e);
    }
  }

  Future<void> recognizeText(String language) async {
    final source = state.selectedImage;
    if (state.busy || source == null) return;
    final token = _begin(ImageOperation.recognizing);
    try {
      final text = await _desktop.recognizeText(source.path, language, token);
      token.check();
      _emit(state.copyWith(recognizedText: text));
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> saveRecognizedText(String title) async {
    final text = state.recognizedText;
    if (state.busy || text == null) return;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      await _desktop.writeText(title, 'ocr.txt', text);
    } catch (e) {
      _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> removeBackground() async {
    final source = state.selectedImage;
    if (state.busy || source == null) return;
    final token = _begin(ImageOperation.removingBackground);
    try {
      final path = await _desktop.removeBackground(source.path, token);
      token.check();
      await _inspect([path], token);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> startWatching(String inputTitle, String outputTitle) async {
    if (state.busy || state.watching) return;
    final token = _begin(ImageOperation.choosingDestination);
    try {
      final input = await _desktop.pickFolder(inputTitle);
      token.check();
      if (input == null) return;
      final output = await _desktop.pickFolder(outputTitle);
      token.check();
      if (output == null) return;
      _watchRecipe = state.recipe;
      _watchOutput = output;
      _watch = _workspace
          .watchFolder(input, output)
          .listen(
            (path) {
              if (!_watchPending.contains(path)) _watchPending.add(path);
              _drainWatch();
            },
            onError: (Object e) {
              _error(e);
              stopWatching();
            },
          );
      _emit(state.copyWith(watching: true, watchFolder: input));
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> _drainWatch() async {
    if (isClosed || state.busy || !state.watching || _watchPending.isEmpty) {
      return;
    }
    final path = _watchPending.removeAt(0);
    final token = _begin(ImageOperation.importing);
    try {
      await _inspect([path], token);
      token.check();
      final source = state.jobs
          .where((j) => j.source.path == p.normalize(p.absolute(path)))
          .firstOrNull
          ?.source;
      if (source == null) return;
      _emit(state.copyWith(operation: ImageOperation.exporting));
      final name = ImageOutputName.build(
        '{name}_edited',
        source,
        _watchRecipe!,
        0,
      );
      await _runOne(source, _watchRecipe!, p.join(_watchOutput!, name), token);
    } catch (e) {
      if (!token.isCancelled) _error(e);
    } finally {
      _end(token);
    }
  }

  Future<void> stopWatching() async {
    await _watch?.cancel();
    _watch = null;
    _watchPending.clear();
    _emit(state.copyWith(watching: false));
  }

  @override
  Future<void> close() async {
    cancel();
    await _watch?.cancel();
    _watchPending.clear();
    await super.close();
    await _desktop.dispose();
  }
}
