import 'package:equatable/equatable.dart';

enum PdfMergeStage { preparing, merging, validating, saving }

sealed class PdfMergeEvent {
  const PdfMergeEvent();
}

class PdfMergeProgress extends PdfMergeEvent {
  final PdfMergeStage stage;
  final double? fraction;
  const PdfMergeProgress(this.stage, {this.fraction});
}

class PdfMergeResult extends Equatable {
  final String path;
  final int pageCount;
  final int sizeBytes;
  const PdfMergeResult({
    required this.path,
    required this.pageCount,
    required this.sizeBytes,
  });
  @override
  List<Object?> get props => [path, pageCount, sizeBytes];
}

class PdfMergeCompleted extends PdfMergeEvent {
  final PdfMergeResult result;
  const PdfMergeCompleted(this.result);
}
