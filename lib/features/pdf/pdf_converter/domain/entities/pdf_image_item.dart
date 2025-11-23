import 'dart:io';
import 'package:equatable/equatable.dart';

class PdfImageItem extends Equatable {
  final String id;
  final File file;
  final bool isSelected;
  final int quarterTurns;

  const PdfImageItem({
    required this.id,
    required this.file,
    this.isSelected = true,
    this.quarterTurns = 0,
  });

  PdfImageItem copyWith({
    String? id,
    File? file,
    bool? isSelected,
    int? quarterTurns,
  }) {
    return PdfImageItem(
      id: id ?? this.id,
      file: file ?? this.file,
      isSelected: isSelected ?? this.isSelected,
      quarterTurns: quarterTurns ?? this.quarterTurns,
    );
  }

  @override
  List<Object?> get props => [id, file, isSelected, quarterTurns];
}
