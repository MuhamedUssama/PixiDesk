import '../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_job.dart';
import '../cubit/image_state.dart';

String imageFailureLabel(AppLocalizations l, ImageFailureCode code) =>
    switch (code) {
      ImageFailureCode.invalidInput => l.imageInvalidInput,
      ImageFailureCode.unsupportedFormat => l.imageUnsupported,
      ImageFailureCode.resourceLimit => l.imageResourceLimit,
      ImageFailureCode.invalidOptions => l.imageInvalidOptions,
      ImageFailureCode.permissionDenied => l.imagePermissionDenied,
      ImageFailureCode.destinationConflict => l.imageDestinationConflict,
      ImageFailureCode.sourceChanged => l.imageSourceChanged,
      ImageFailureCode.encodeFailed => l.imageEncodeFailed,
      ImageFailureCode.cancelled => l.imageCancelled,
      ImageFailureCode.invalidPreset => l.imageInvalidPreset,
      ImageFailureCode.storageFailed => l.imageStorageFailed,
      ImageFailureCode.toolUnavailable => l.imageToolUnavailable,
      ImageFailureCode.toolFailed => l.imageToolFailed,
    };
String imageStatusLabel(AppLocalizations l, ImageJobStatus status) =>
    switch (status) {
      ImageJobStatus.pending => l.imagePending,
      ImageJobStatus.running => l.imageRunning,
      ImageJobStatus.completed => l.imageCompleted,
      ImageJobStatus.failed => l.imageFailed,
      ImageJobStatus.cancelled => l.imageCancelled,
      ImageJobStatus.skipped => l.imageSkipped,
    };
String imageOperationLabel(AppLocalizations l, ImageOperation operation) =>
    switch (operation) {
      ImageOperation.idle => l.imageQueue,
      ImageOperation.importing => l.imageImporting,
      ImageOperation.choosingDestination => l.imageChoosing,
      ImageOperation.exporting => l.imageProcessing,
      ImageOperation.previewing => l.imagePreviewing,
      ImageOperation.recognizing => l.imageRecognizing,
      ImageOperation.removingBackground => l.imageRemovingBackground,
    };
String imageNoticeLabel(AppLocalizations l, ImageNotice notice) =>
    switch (notice) {
      ImageNotice.unchanged => l.imageUnchanged,
      ImageNotice.noSavings => l.imageNoSavings,
      ImageNotice.targetNotReached => l.imageTargetNotReached,
      ImageNotice.animationFlattened => l.imageAnimationFlattened,
      ImageNotice.alphaFlattened => l.imageAlphaFlattened,
      ImageNotice.metadataLimited => l.imageMetadataLimited,
    };
String imageSizeLabel(AppLocalizations l, int bytes) {
  final unit = bytes >= 1048576
      ? l.imageMbUnit
      : bytes >= 1024
      ? l.imageKbUnit
      : l.imageBytesUnit;
  final value = bytes >= 1048576
      ? bytes / 1048576
      : bytes >= 1024
      ? bytes / 1024
      : bytes.toDouble();
  return l.imageFileSize(value.toStringAsFixed(1), unit);
}
