import 'pdf_merge_document.dart';
import 'pdf_merge_failure.dart';

class PdfMergeRequest {
  final List<PdfMergeDocument> documents;
  final String destinationPath;
  final bool acknowledgeDocumentChanges;
  PdfMergeRequest({
    required List<PdfMergeDocument> documents,
    required this.destinationPath,
    required this.acknowledgeDocumentChanges,
  }) : documents = List.unmodifiable(documents);

  int get totalPages => documents.fold(
    0,
    (count, document) => count + document.selectedPages.length,
  );

  void validate() {
    if (documents.isEmpty ||
        documents.length > 100 ||
        totalPages == 0 ||
        totalPages > 20000 ||
        documents.fold<int>(
              0,
              (total, document) => total + document.sizeBytes,
            ) >
            4 * 1024 * 1024 * 1024) {
      throw const PdfMergeFailure(PdfMergeFailureCode.resourceLimit);
    }
    if (!acknowledgeDocumentChanges || destinationPath.isEmpty) {
      throw const PdfMergeFailure(PdfMergeFailureCode.mergeFailed);
    }
    for (final document in documents) {
      if (document.pageCount < 1 ||
          document.pageCount > 20000 ||
          document.sizeBytes < 1 ||
          document.sizeBytes > 512 * 1024 * 1024 ||
          document.selectedPages.any(
            (page) => page < 0 || page >= document.pageCount,
          ) ||
          document.rotations.keys.any(
            (page) => page < 0 || page >= document.pageCount,
          ) ||
          document.rotations.values.any(
            (rotation) => rotation < 0 || rotation > 3,
          )) {
        throw const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange);
      }
    }
  }
}

/// One-based user ranges retain explicit ordering and repeated page references.
List<int> parsePdfPageRange(String value, int pageCount) {
  if (pageCount < 1 || pageCount > 20000 || value.length > 200000) {
    throw const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange);
  }
  if (value.trim().isEmpty) return List.generate(pageCount, (index) => index);
  final selection = <int>[];
  for (final token in value.split(',')) {
    final match = RegExp(r'^\s*(\d+)\s*(?:-\s*(\d+|z)\s*)?$').firstMatch(token);
    if (match == null) {
      throw const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange);
    }
    final first = int.tryParse(match.group(1)!);
    final last = match.group(2) == 'z'
        ? pageCount
        : int.tryParse(match.group(2) ?? match.group(1)!);
    if (first == null ||
        last == null ||
        first < 1 ||
        last < 1 ||
        first > pageCount ||
        last > pageCount ||
        selection.length + (last - first).abs() + 1 > 20000) {
      throw const PdfMergeFailure(PdfMergeFailureCode.invalidPageRange);
    }
    final step = first <= last ? 1 : -1;
    for (var page = first; ; page += step) {
      selection.add(page - 1);
      if (page == last) break;
    }
  }
  return List.unmodifiable(selection);
}
