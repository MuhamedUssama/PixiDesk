import 'dart:io';
import 'package:equatable/equatable.dart';

class PdfImageItem extends Equatable {
  final String id;
  final File file;
  final bool isSelected;

  const PdfImageItem({
    required this.id,
    required this.file,
    this.isSelected = true,
  });

  PdfImageItem copyWith({String? id, File? file, bool? isSelected}) {
    return PdfImageItem(
      id: id ?? this.id,
      file: file ?? this.file,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, file, isSelected];
}
