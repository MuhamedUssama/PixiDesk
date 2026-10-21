import '../../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/pdf_conversion_failure.dart';

String pdfFailureLabel(
  AppLocalizations localizations,
  PdfConversionFailureCode code,
) => switch (code) {
  PdfConversionFailureCode.unsupportedPlatform =>
    localizations.pdfPlatformUnsupported,
  PdfConversionFailureCode.engineUnavailable =>
    localizations.pdfEngineUnavailable,
  PdfConversionFailureCode.invalidDocument => localizations.pdfInvalidDocument,
  PdfConversionFailureCode.passwordRequired =>
    localizations.pdfPasswordRequired,
  PdfConversionFailureCode.invalidSettings => localizations.pdfInvalidSettings,
  PdfConversionFailureCode.resourceLimit => localizations.pdfResourceLimit,
  PdfConversionFailureCode.sourceChanged => localizations.pdfSourceChanged,
  PdfConversionFailureCode.permissionDenied =>
    localizations.imagePermissionDenied,
  PdfConversionFailureCode.destinationConflict =>
    localizations.imageDestinationConflict,
  PdfConversionFailureCode.cancelled => localizations.imageCancelled,
  PdfConversionFailureCode.busy => localizations.pdfJobBusy,
  PdfConversionFailureCode.timedOut => localizations.pdfConversionTimedOut,
  PdfConversionFailureCode.saveFailed => localizations.pdfSaveFailed,
  PdfConversionFailureCode.workerFailed => localizations.pdfWorkerFailed,
};
