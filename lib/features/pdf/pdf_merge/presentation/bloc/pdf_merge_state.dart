import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/pdf_merge_document.dart';
import '../../domain/entities/pdf_merge_event.dart';
import '../../domain/entities/pdf_merge_failure.dart';
part 'pdf_merge_state.freezed.dart';

enum PdfMergeStatus {
  initial,
  picking,
  importing,
  awaitingPassword,
  merging,
  cancelling,
  completed,
}

@freezed
abstract class PdfMergeState with _$PdfMergeState {
  const PdfMergeState._();
  const factory PdfMergeState({
    @Default([]) List<PdfMergeDocument> documents,
    @Default(PdfMergeStatus.initial) PdfMergeStatus status,
    @Default(false) bool acknowledgeDocumentChanges,
    @Default({}) Set<String> invalidRangeDocumentIds,
    PdfMergeStage? stage,
    double? progress,
    PdfMergeResult? result,
    PdfMergeFailureCode? failure,
    @Default(0) int messageId,
    String? passwordPath,
    @Default([]) List<String> pendingImportPaths,
    String? previewDocumentId,
    @Default(0) int previewPageIndex,
    String? previewPath,
    @Default(false) bool isPreviewLoading,
    PdfMergeFailureCode? previewFailure,
  }) = _PdfMergeState;
  bool get isBusy =>
      status == PdfMergeStatus.picking ||
      status == PdfMergeStatus.importing ||
      status == PdfMergeStatus.merging ||
      status == PdfMergeStatus.cancelling;
  bool get canEdit => !isBusy && passwordPath == null;
  int get totalPages => documents.fold(
    0,
    (total, document) => total + document.selectedPages.length,
  );
  int get totalBytes =>
      documents.fold(0, (total, document) => total + document.sizeBytes);
  bool get canMerge =>
      canEdit &&
      invalidRangeDocumentIds.isEmpty &&
      acknowledgeDocumentChanges &&
      totalPages > 0 &&
      documents.isNotEmpty;
  PdfMergeDocument? get previewDocument => documents
      .where((document) => document.id == previewDocumentId)
      .firstOrNull;
}
