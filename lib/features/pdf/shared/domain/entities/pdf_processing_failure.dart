enum PdfProcessingFailureCode {
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

class PdfProcessingFailure implements Exception {
  final PdfProcessingFailureCode code;
  const PdfProcessingFailure(this.code);
}
