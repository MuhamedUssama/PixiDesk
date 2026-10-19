import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';

enum ImageOperation {
  idle,
  importing,
  choosingDestination,
  exporting,
  previewing,
  recognizing,
  removingBackground,
}

class ImageState extends Equatable {
  final List<ImageJob> jobs;
  final int selectedIndex;
  final ImageRecipe recipe;
  final ImageOperation operation;
  final ImageFailureCode? failure;
  final int messageId;
  final Uint8List? preview;
  final List<ImagePreset> presets;
  final List<ImageHistoryEntry> history;
  final List<ImageHistoryEntry> recovery;
  final String? outputFolder;
  final String namingPattern;
  final OutputConflict conflict;
  final int finished, total;
  final bool paused, watching, canUndo, canRedo;
  final String? watchFolder;
  final String? recognizedText;
  const ImageState({
    this.jobs = const [],
    this.selectedIndex = 0,
    this.recipe = const ImageRecipe(),
    this.operation = ImageOperation.idle,
    this.failure,
    this.messageId = 0,
    this.preview,
    this.presets = const [],
    this.history = const [],
    this.recovery = const [],
    this.outputFolder,
    this.namingPattern = '{name}_edited',
    this.conflict = OutputConflict.rename,
    this.finished = 0,
    this.total = 0,
    this.paused = false,
    this.watching = false,
    this.watchFolder,
    this.canUndo = false,
    this.canRedo = false,
    this.recognizedText,
  });
  bool get busy => operation != ImageOperation.idle;
  ImageJob? get selectedJob => selectedIndex >= 0 && selectedIndex < jobs.length
      ? jobs[selectedIndex]
      : null;
  ImageEntity? get selectedImage => selectedJob?.source;
  ImageResult? get result => selectedJob?.result;
  ImageState copyWith({
    List<ImageJob>? jobs,
    int? selectedIndex,
    ImageRecipe? recipe,
    ImageOperation? operation,
    ImageFailureCode? failure,
    bool clearFailure = false,
    int? messageId,
    Uint8List? preview,
    bool clearPreview = false,
    List<ImagePreset>? presets,
    List<ImageHistoryEntry>? history,
    List<ImageHistoryEntry>? recovery,
    String? outputFolder,
    String? namingPattern,
    OutputConflict? conflict,
    int? finished,
    int? total,
    bool? paused,
    bool? watching,
    String? watchFolder,
    bool? canUndo,
    bool? canRedo,
    String? recognizedText,
    bool clearText = false,
  }) => ImageState(
    jobs: jobs == null ? this.jobs : List.unmodifiable(jobs),
    selectedIndex: selectedIndex ?? this.selectedIndex,
    recipe: recipe ?? this.recipe,
    operation: operation ?? this.operation,
    failure: clearFailure ? null : failure ?? this.failure,
    messageId: messageId ?? this.messageId,
    preview: clearPreview ? null : preview ?? this.preview,
    presets: presets == null ? this.presets : List.unmodifiable(presets),
    history: history == null ? this.history : List.unmodifiable(history),
    recovery: recovery == null ? this.recovery : List.unmodifiable(recovery),
    outputFolder: outputFolder ?? this.outputFolder,
    namingPattern: namingPattern ?? this.namingPattern,
    conflict: conflict ?? this.conflict,
    finished: finished ?? this.finished,
    total: total ?? this.total,
    paused: paused ?? this.paused,
    watching: watching ?? this.watching,
    watchFolder: watchFolder ?? this.watchFolder,
    canUndo: canUndo ?? this.canUndo,
    canRedo: canRedo ?? this.canRedo,
    recognizedText: clearText ? null : recognizedText ?? this.recognizedText,
  );
  @override
  List<Object?> get props => [
    jobs,
    selectedIndex,
    recipe,
    operation,
    failure,
    messageId,
    preview,
    presets,
    history,
    recovery,
    outputFolder,
    namingPattern,
    conflict,
    finished,
    total,
    paused,
    watching,
    watchFolder,
    canUndo,
    canRedo,
    recognizedText,
  ];
}
