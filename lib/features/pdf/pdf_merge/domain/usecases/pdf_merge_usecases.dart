import '../entities/pdf_merge_document.dart';
import '../entities/pdf_merge_event.dart';
import '../entities/pdf_merge_request.dart';
import '../repositories/pdf_merge_repository.dart';

class InspectPdfForMergeUseCase {
  final PdfMergeRepository _repository;
  InspectPdfForMergeUseCase(this._repository);
  Future<PdfMergeDocument> call(String path, {String? password}) =>
      _repository.inspect(path, password: password);
}

class MergePdfsUseCase {
  final PdfMergeRepository _repository;
  MergePdfsUseCase(this._repository);
  Stream<PdfMergeEvent> call(PdfMergeRequest request) {
    request.validate();
    return _repository.merge(request);
  }
}

class PreviewMergePageUseCase {
  final PdfMergeRepository _repository;
  PreviewMergePageUseCase(this._repository);
  Future<String> call(PdfMergeDocument document, int pageIndex) =>
      _repository.preview(document, pageIndex);
}

class ManagePdfMergeSessionUseCase {
  final PdfMergeRepository _repository;
  ManagePdfMergeSessionUseCase(this._repository);
  Future<void> forget(String id) => _repository.forget(id);
  Future<void> cancel() => _repository.cancel();
  Future<void> dispose() => _repository.dispose();
}
