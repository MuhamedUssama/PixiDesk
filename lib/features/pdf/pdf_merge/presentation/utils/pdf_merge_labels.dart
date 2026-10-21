import '../../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/pdf_merge_failure.dart';
import '../../domain/entities/pdf_merge_event.dart';

String pdfMergeFailureLabel(
  AppLocalizations localizations,
  PdfMergeFailureCode code,
) => switch (code) {
  PdfMergeFailureCode.engineUnavailable =>
    localizations.pdfMergeEngineUnavailable,
  PdfMergeFailureCode.invalidDocument => localizations.pdfInvalidDocument,
  PdfMergeFailureCode.passwordRequired =>
    localizations.pdfMergePasswordRejected,
  PdfMergeFailureCode.unsupportedDocument =>
    localizations.pdfMergeUnsupportedDocument,
  PdfMergeFailureCode.invalidPageRange => localizations.pdfMergeInvalidRange,
  PdfMergeFailureCode.resourceLimit => localizations.pdfMergeResourceLimit,
  PdfMergeFailureCode.sourceChanged => localizations.pdfSourceChanged,
  PdfMergeFailureCode.sourceProtected => localizations.pdfMergeSourceProtected,
  PdfMergeFailureCode.destinationConflict =>
    localizations.imageDestinationConflict,
  PdfMergeFailureCode.permissionDenied => localizations.imagePermissionDenied,
  PdfMergeFailureCode.cancelled => localizations.imageCancelled,
  PdfMergeFailureCode.timedOut => localizations.pdfMergeTimedOut,
  PdfMergeFailureCode.busy => localizations.pdfJobBusy,
  PdfMergeFailureCode.mergeFailed => localizations.pdfMergeFailed,
  PdfMergeFailureCode.previewUnavailable =>
    localizations.pdfMergePreviewUnavailable,
  PdfMergeFailureCode.launchFailed => localizations.pdfMergeLaunchFailed,
};
String pdfMergeStageLabel(
  AppLocalizations localizations,
  PdfMergeStage? stage,
) => switch (stage) {
  PdfMergeStage.preparing || null => localizations.preparing,
  PdfMergeStage.merging => localizations.pdfMergeWriting,
  PdfMergeStage.validating => localizations.pdfMergeValidating,
  PdfMergeStage.saving => localizations.pdfMergeSaving,
};

String formatPdfPageRange(List<int> pages) {
  final ranges = <String>[];
  for (var index = 0; index < pages.length; index++) {
    final start = pages[index] + 1;
    var end = start;
    final step = index + 1 < pages.length ? pages[index + 1] - pages[index] : 0;
    if (step.abs() == 1) {
      while (index + 1 < pages.length &&
          pages[index + 1] - pages[index] == step) {
        index++;
        end = pages[index] + 1;
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');
  }
  return ranges.join(',');
}
