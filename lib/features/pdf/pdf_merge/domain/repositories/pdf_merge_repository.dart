import '../entities/pdf_merge_document.dart';
import '../entities/pdf_merge_event.dart';
import '../entities/pdf_merge_request.dart';

abstract class PdfMergeRepository {
  Future<PdfMergeDocument> inspect(String path, {String? password});
  Stream<PdfMergeEvent> merge(PdfMergeRequest request);
  Future<String> preview(PdfMergeDocument document, int pageIndex);
  Future<void> forget(String documentId);
  Future<void> cancel();
  Future<void> dispose();
}
