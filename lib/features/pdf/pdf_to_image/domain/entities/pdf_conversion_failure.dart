enum PdfConversionFailureCode {
  engineUnavailable,
  unsupportedPlatform,
  invalidDocument,
  passwordRequired,
  invalidSettings,
  resourceLimit,
  destinationConflict,
  sourceChanged,
  permissionDenied,
  cancelled,
  busy,
  workerFailed,
  timedOut,
  saveFailed,
}

class PdfConversionFailure implements Exception {
  final PdfConversionFailureCode code;
  const PdfConversionFailure(this.code);
}
