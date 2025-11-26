import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:file_picker/file_picker.dart';

@injectable
class PdfToImageCubit extends Cubit<PdfToImageState> {
  final ConvertPdfToImagesUseCase _convertPdfToImagesUseCase;
  final SaveImagesUseCase _saveImagesUseCase;

  PdfToImageCubit(this._convertPdfToImagesUseCase, this._saveImagesUseCase)
    : super(const PdfToImageState());

  void selectFile(File file) {
    emit(
      state.copyWith(
        selectedFile: file,
        status: PdfToImageStatus.initial,
        generatedImages: null,
        progress: null,
        errorMessage: null,
      ),
    );
  }

  void updateSettings({String? format, int? dpi}) {
    emit(state.copyWith(outputFormat: format, dpi: dpi));
  }

  void clearFile() {
    emit(const PdfToImageState());
  }

  void toggleImageSelection(String path) {
    final currentSelection = Set<String>.from(state.selectedImagePaths);
    if (currentSelection.contains(path)) {
      currentSelection.remove(path);
    } else {
      currentSelection.add(path);
    }
    emit(state.copyWith(selectedImagePaths: currentSelection));
  }

  void rotateImage(String path) {
    final currentRotations = Map<String, int>.from(state.imageRotations);
    final currentRotation = currentRotations[path] ?? 0;
    currentRotations[path] = (currentRotation + 1) % 4;
    emit(state.copyWith(imageRotations: currentRotations));
  }

  void deleteSelectedImages() {
    if (state.generatedImages == null) return;

    final remainingImages = state.generatedImages!
        .where((file) => !state.selectedImagePaths.contains(file.path))
        .toList();

    // Clean up rotations for deleted images
    final currentRotations = Map<String, int>.from(state.imageRotations);
    for (final path in state.selectedImagePaths) {
      currentRotations.remove(path);
    }

    emit(
      state.copyWith(
        generatedImages: remainingImages,
        selectedImagePaths: {},
        imageRotations: currentRotations,
      ),
    );
  }

  void clearSelection() {
    emit(state.copyWith(selectedImagePaths: {}));
  }

  Future<void> triggerSaveAll() async {
    if (state.generatedImages == null || state.generatedImages!.isEmpty) return;

    final String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;

    emit(state.copyWith(status: PdfToImageStatus.saving));

    try {
      await _saveImagesUseCase(
        state.generatedImages!,
        directoryPath,
        state.imageRotations,
      );
      emit(
        state.copyWith(
          status: PdfToImageStatus.savedSuccess,
          successMessage: 'Files saved successfully',
        ),
      );
      // Reset status back to review after showing success
      emit(
        state.copyWith(status: PdfToImageStatus.review, successMessage: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PdfToImageStatus.error,
          errorMessage: 'Error saving files: $e',
        ),
      );
    }
  }

  Future<void> startConversion() async {
    if (state.selectedFile == null) return;

    emit(state.copyWith(status: PdfToImageStatus.converting));

    final params = PdfToImageParams(
      inputFile: state.selectedFile!,
      outputFormat: state.outputFormat,
      dpi: state.dpi,
    );

    try {
      final stream = _convertPdfToImagesUseCase(params);

      await for (final event in stream) {
        if (event is PdfToImageProgress) {
          emit(state.copyWith(progress: event.progress));
        } else if (event is PdfToImageCompleted) {
          emit(
            state.copyWith(
              status: PdfToImageStatus.review,
              generatedImages: event.images,
              progress: null,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PdfToImageStatus.error,
          errorMessage: 'Error converting PDF to images',
        ),
      );
    }
  }

  void reset() {
    emit(state.copyWith(status: PdfToImageStatus.initial));
  }
}
