import '../../../../../l10n/localization/app_localizations.dart';
import '../../../shared/domain/entities/pdf_processing_failure.dart';

String pdfFailureLabel(
  AppLocalizations localizations,
  PdfProcessingFailureCode code,
) => switch (code) {
  PdfProcessingFailureCode.unsupportedPlatform =>
    localizations.pdfPlatformUnsupported,
  PdfProcessingFailureCode.engineUnavailable =>
    localizations.pdfEngineUnavailable,
  PdfProcessingFailureCode.invalidDocument => localizations.pdfInvalidDocument,
  PdfProcessingFailureCode.passwordRequired =>
    localizations.pdfPasswordRequired,
  PdfProcessingFailureCode.invalidSettings => localizations.pdfInvalidSettings,
  PdfProcessingFailureCode.resourceLimit => localizations.pdfResourceLimit,
  PdfProcessingFailureCode.sourceChanged => localizations.pdfSourceChanged,
  PdfProcessingFailureCode.permissionDenied =>
    localizations.imagePermissionDenied,
  PdfProcessingFailureCode.destinationConflict =>
    localizations.imageDestinationConflict,
  PdfProcessingFailureCode.cancelled => localizations.imageCancelled,
  PdfProcessingFailureCode.busy => localizations.pdfJobBusy,
  PdfProcessingFailureCode.timedOut => localizations.pdfConversionTimedOut,
  PdfProcessingFailureCode.saveFailed => localizations.pdfSaveFailed,
  PdfProcessingFailureCode.workerFailed => localizations.pdfWorkerFailed,
};
