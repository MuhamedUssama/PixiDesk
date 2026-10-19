import 'dart:io';

sealed class PdfToImageAction {
  const PdfToImageAction();
}

class PdfFilesSelected extends PdfToImageAction {
  final List<File> files;
  PdfFilesSelected(List<File> files) : files = List.unmodifiable(files);
}

class PdfFileRemoved extends PdfToImageAction {
  final String path;
  const PdfFileRemoved(this.path);
}

class PdfSettingsChanged extends PdfToImageAction {
  final String? format;
  final int? dpi;
  const PdfSettingsChanged({this.format, this.dpi});
}

class PdfClearRequested extends PdfToImageAction {
  const PdfClearRequested();
}

class PdfConversionRequested extends PdfToImageAction {
  const PdfConversionRequested();
}

class PdfCancellationRequested extends PdfToImageAction {
  const PdfCancellationRequested();
}

class PdfSelectionToggled extends PdfToImageAction {
  final String path;
  const PdfSelectionToggled(this.path);
}

class PdfPageRotated extends PdfToImageAction {
  final String path;
  const PdfPageRotated(this.path);
}

class PdfSelectedPagesDeleted extends PdfToImageAction {
  const PdfSelectedPagesDeleted();
}

class PdfSelectionCleared extends PdfToImageAction {
  const PdfSelectionCleared();
}

enum PdfExportMode { folder, archive, separateArchives }

class PdfExportRequested extends PdfToImageAction {
  final PdfExportMode mode;
  final String dialogTitle;
  const PdfExportRequested(this.mode, {this.dialogTitle = ''});
}

class PdfReviewRequested extends PdfToImageAction {
  const PdfReviewRequested();
}
