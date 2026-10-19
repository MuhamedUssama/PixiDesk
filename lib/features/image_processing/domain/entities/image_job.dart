import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'image_entity.dart';
import 'image_failure.dart';
import 'image_recipe.dart';

enum ImageJobStatus { pending, running, completed, failed, cancelled, skipped }

enum ImageNotice {
  unchanged,
  noSavings,
  targetNotReached,
  animationFlattened,
  alphaFlattened,
  metadataLimited,
}

class ImageRequest {
  final ImageEntity source;
  final ImageRecipe recipe;
  final String destinationPath;
  final OutputConflict conflict;
  final bool keepSmaller;
  final List<String> protectedPaths;
  const ImageRequest({
    required this.source,
    required this.recipe,
    required this.destinationPath,
    this.conflict = OutputConflict.rename,
    this.keepSmaller = false,
    this.protectedPaths = const [],
  });
}

class ImageResult extends Equatable {
  final String path;
  final int originalBytes, outputBytes, width, height;
  final Duration elapsed;
  final List<ImageNotice> notices;
  final Uint8List thumbnail;
  final bool skipped;
  const ImageResult({
    required this.path,
    required this.originalBytes,
    required this.outputBytes,
    required this.width,
    required this.height,
    required this.elapsed,
    required this.thumbnail,
    this.notices = const [],
    this.skipped = false,
  });
  double get savings =>
      originalBytes == 0 ? 0 : (1 - outputBytes / originalBytes) * 100;
  @override
  List<Object?> get props => [
    path,
    outputBytes,
    width,
    height,
    elapsed,
    notices,
    skipped,
  ];
}

class ImageJob extends Equatable {
  final ImageEntity source;
  final ImageJobStatus status;
  final ImageResult? result;
  final ImageFailureCode? failure;
  const ImageJob({
    required this.source,
    this.status = ImageJobStatus.pending,
    this.result,
    this.failure,
  });
  ImageJob copyWith({
    ImageJobStatus? status,
    ImageResult? result,
    ImageFailureCode? failure,
    bool reset = false,
  }) => ImageJob(
    source: source,
    status: status ?? this.status,
    result: reset ? null : result ?? this.result,
    failure: reset ? null : failure ?? this.failure,
  );
  @override
  List<Object?> get props => [source, status, result, failure];
}

class ImagePreset extends Equatable {
  final String id, name;
  final ImageRecipe recipe;
  const ImagePreset({
    required this.id,
    required this.name,
    required this.recipe,
  });
  @override
  List<Object?> get props => [id, name, recipe];
}

class ImageHistoryEntry extends Equatable {
  final String id, sourcePath, outputPath;
  final int sourceBytes, sourceModifiedMicros, outputBytes;
  final DateTime createdAt;
  final ImageRecipe recipe;
  const ImageHistoryEntry({
    required this.id,
    required this.sourcePath,
    required this.outputPath,
    required this.sourceBytes,
    required this.sourceModifiedMicros,
    required this.outputBytes,
    required this.createdAt,
    required this.recipe,
  });
  @override
  List<Object?> get props => [id];
}

class ImageWorkspace {
  final List<ImagePreset> presets;
  final List<ImageHistoryEntry> history;
  final List<ImageHistoryEntry> recovery;
  const ImageWorkspace({
    this.presets = const [],
    this.history = const [],
    this.recovery = const [],
  });
}
