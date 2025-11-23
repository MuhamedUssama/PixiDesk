import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/pdf_config.dart';
import '../../domain/entities/pdf_image_item.dart';
import '../../domain/usecases/generate_pdf_use_case.dart';
import 'pdf_converter_state.dart';

@injectable
class PdfConverterCubit extends Cubit<PdfConverterState> {
  final GeneratePdfUseCase _generatePdfUseCase;
  final Uuid _uuid = const Uuid();

  PdfConverterCubit(this._generatePdfUseCase)
    : super(const PdfConverterState());

  void addImages(List<File> files) {
    final newImages = files.map((file) {
      return PdfImageItem(id: _uuid.v4(), file: file);
    }).toList();

    emit(
      state.copyWith(
        images: [...state.images, ...newImages],
        status: PdfConverterStatus.initial,
      ),
    );
  }

  void removeImage(String id) {
    final newImages = state.images.where((img) => img.id != id).toList();
    emit(state.copyWith(images: newImages));
  }

  void toggleSelection(String id) {
    final newImages = state.images.map((img) {
      if (img.id == id) {
        return img.copyWith(isSelected: !img.isSelected);
      }
      return img;
    }).toList();
    emit(state.copyWith(images: newImages));
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newImages = List<PdfImageItem>.from(state.images);
    final item = newImages.removeAt(oldIndex);
    newImages.insert(newIndex, item);
    emit(state.copyWith(images: newImages));
  }

  void changeViewMode(bool isGridView) {
    emit(state.copyWith(isGridView: isGridView));
  }

  void updateConfig(PdfConfig config) {
    emit(state.copyWith(config: config));
  }

  Future<void> generatePdf(String outputPath) async {
    final selectedImages = state.images.where((img) => img.isSelected).toList();
    if (selectedImages.isEmpty) {
      emit(
        state.copyWith(
          status: PdfConverterStatus.error,
          errorMessage: 'No images selected',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PdfConverterStatus.loading));

    try {
      final pdfFile = await _generatePdfUseCase(
        images: selectedImages,
        config: state.config,
        outputPath: outputPath,
      );
      emit(
        state.copyWith(
          status: PdfConverterStatus.success,
          generatedPdf: pdfFile,
        ),
      );
      // Reset status to initial to prevent repeated success messages
      emit(state.copyWith(status: PdfConverterStatus.initial));
    } catch (e) {
      emit(
        state.copyWith(
          status: PdfConverterStatus.error,
          errorMessage: e.toString(),
        ),
      );
      // Reset status to initial to prevent repeated error messages
      emit(state.copyWith(status: PdfConverterStatus.initial));
    }
  }
}
