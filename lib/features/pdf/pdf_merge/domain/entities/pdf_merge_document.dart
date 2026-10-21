import 'package:equatable/equatable.dart';

class PdfMergeDocument extends Equatable {
  final String id;
  final String path;
  final String displayName;
  final int pageCount;
  final int sizeBytes;
  final int modifiedMicroseconds;
  final int changedMicroseconds;
  final bool isEncrypted;
  final List<int> selectedPages;
  final Map<int, int> rotations;

  PdfMergeDocument({
    required this.id,
    required this.path,
    required this.displayName,
    required this.pageCount,
    required this.sizeBytes,
    required this.modifiedMicroseconds,
    required this.changedMicroseconds,
    this.isEncrypted = false,
    required List<int> selectedPages,
    Map<int, int> rotations = const {},
  }) : selectedPages = List.unmodifiable(selectedPages),
       rotations = Map.unmodifiable(rotations);

  PdfMergeDocument copyWith({
    List<int>? selectedPages,
    Map<int, int>? rotations,
  }) => PdfMergeDocument(
    id: id,
    path: path,
    displayName: displayName,
    pageCount: pageCount,
    sizeBytes: sizeBytes,
    modifiedMicroseconds: modifiedMicroseconds,
    changedMicroseconds: changedMicroseconds,
    isEncrypted: isEncrypted,
    selectedPages: selectedPages ?? this.selectedPages,
    rotations: rotations ?? this.rotations,
  );

  @override
  List<Object?> get props => [
    id,
    path,
    displayName,
    pageCount,
    sizeBytes,
    modifiedMicroseconds,
    changedMicroseconds,
    isEncrypted,
    selectedPages,
    rotations,
  ];
}
