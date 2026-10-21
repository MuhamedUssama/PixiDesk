enum PdfMergeFailureCode {
  engineUnavailable,
  invalidDocument,
  passwordRequired,
  unsupportedDocument,
  invalidPageRange,
  resourceLimit,
  sourceChanged,
  sourceProtected,
  destinationConflict,
  permissionDenied,
  cancelled,
  timedOut,
  busy,
  mergeFailed,
  previewUnavailable,
  launchFailed,
}

class PdfMergeFailure implements Exception {
  final PdfMergeFailureCode code;
  const PdfMergeFailure(this.code);
}
