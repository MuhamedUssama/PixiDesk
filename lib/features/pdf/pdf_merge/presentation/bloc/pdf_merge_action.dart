sealed class PdfMergeAction {
  const PdfMergeAction();
}

class PdfMergePickRequested extends PdfMergeAction {
  const PdfMergePickRequested();
}

class PdfMergeImportRequested extends PdfMergeAction {
  final List<String> paths;
  final String? password;
  PdfMergeImportRequested(List<String> paths, {this.password})
    : paths = List.unmodifiable(paths);
}

class PdfMergePasswordDismissed extends PdfMergeAction {
  const PdfMergePasswordDismissed();
}

class PdfMergeDocumentRemoved extends PdfMergeAction {
  final String id;
  const PdfMergeDocumentRemoved(this.id);
}

class PdfMergeDocumentsCleared extends PdfMergeAction {
  const PdfMergeDocumentsCleared();
}

class PdfMergeDocumentMoved extends PdfMergeAction {
  final int fromIndex, toIndex;
  const PdfMergeDocumentMoved(this.fromIndex, this.toIndex);
}

class PdfMergePagesChanged extends PdfMergeAction {
  final String id;
  final List<int> pages;
  PdfMergePagesChanged(this.id, List<int> pages)
    : pages = List.unmodifiable(pages);
}

class PdfMergePageRotated extends PdfMergeAction {
  final String id;
  final int? pageIndex;
  const PdfMergePageRotated(this.id, {this.pageIndex});
}

class PdfMergeAcknowledgementChanged extends PdfMergeAction {
  final bool value;
  const PdfMergeAcknowledgementChanged(this.value);
}

class PdfMergeRequested extends PdfMergeAction {
  final String dialogTitle;
  const PdfMergeRequested(this.dialogTitle);
}

class PdfMergeCancelRequested extends PdfMergeAction {
  const PdfMergeCancelRequested();
}

class PdfMergePreviewRequested extends PdfMergeAction {
  final String id;
  final int pageIndex;
  const PdfMergePreviewRequested(this.id, this.pageIndex);
}

class PdfMergePreviewClosed extends PdfMergeAction {
  const PdfMergePreviewClosed();
}

class PdfMergeOutputOpened extends PdfMergeAction {
  final bool reveal;
  const PdfMergeOutputOpened({this.reveal = false});
}

class PdfMergeRangeEdited extends PdfMergeAction {
  final String id, text;
  const PdfMergeRangeEdited(this.id, this.text);
}
