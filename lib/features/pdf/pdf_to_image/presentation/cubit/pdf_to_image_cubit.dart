import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_as_zip_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_as_separate_zips_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:file_picker/file_picker.dart';

@injectable
class PdfToImageCubit extends Cubit<PdfToImageState> {
  final ConvertPdfToImagesUseCase _convertPdfToImagesUseCase;
  final SaveImagesUseCase _saveImagesUseCase;
  final SaveAsZipUseCase _saveAsZipUseCase;
  final SaveAsSeparateZipsUseCase _saveAsSeparateZipsUseCase;
  StreamSubscription? _conversionSubscription;

  PdfToImageCubit(
    this._convertPdfToImagesUseCase,
    this._saveImagesUseCase,
    this._saveAsZipUseCase,
    this._saveAsSeparateZipsUseCase,
  ) : super(const PdfToImageState());

  void selectFiles(List<File> files) {
    final currentFiles = List<File>.from(state.selectedFiles);
    currentFiles.addAll(files);
    // Remove duplicates based on path
    final uniqueFiles = <String, File>{};
    for (final file in currentFiles) {
      uniqueFiles[file.path] = file;
    }

    emit(
      state.copyWith(
        selectedFiles: uniqueFiles.values.toList(),
        status: PdfToImageStatus.initial,
        generatedImages: null,
        progress: null,
        errorMessage: null,
      ),
    );
  }

  void removeFile(File file) {
    final currentFiles = List<File>.from(state.selectedFiles);
    currentFiles.removeWhere((f) => f.path == file.path);
    emit(state.copyWith(selectedFiles: currentFiles));
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

    // If multiple files, we need to ask the user (handled by UI based on this check,
    // or we can emit a status, but the requirement says UI renders based on state).
    // Actually, the requirement says: "The Cubit is responsible for knowing when to present the download options".
    // So we can return a Future<bool> or emit a state.
    // Let's assume the UI calls this method when "Save" is clicked.
    // If we have multiple files, we shouldn't just save.
    // But wait, the UI needs to show the dialog.
    // If I emit a status `downloadOptionsRequired`, the UI can listen and show dialog.

    if (state.selectedFiles.length > 1) {
      // The UI should check this before calling triggerSaveAll, OR
      // we can have a method `onSaveClicked` that decides.
      // Let's rename this to `saveCombined` and add `saveSeparateZips`.
      // And have a helper `shouldShowDownloadOptions`.
    }

    // This method will now strictly be "Save Combined" (Option 1 or Single File)
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

  Future<void> saveAsSeparateZips() async {
    if (state.groupedImages.isEmpty) return;

    final String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;

    emit(state.copyWith(status: PdfToImageStatus.saving));

    try {
      await _saveAsSeparateZipsUseCase(
        groupedImages: state.groupedImages,
        destinationDirectory: directoryPath,
        rotations: state.imageRotations,
      );
      emit(
        state.copyWith(
          status: PdfToImageStatus.savedSuccess,
          successMessage: 'ZIP files saved successfully',
        ),
      );
      emit(
        state.copyWith(status: PdfToImageStatus.review, successMessage: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PdfToImageStatus.error,
          errorMessage: 'Error saving ZIP files: $e',
        ),
      );
    }
  }

  Future<void> saveAsZip() async {
    if (state.generatedImages == null || state.generatedImages!.isEmpty) return;

    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save as ZIP',
      fileName: 'converted_images.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (filePath == null) return;

    emit(state.copyWith(status: PdfToImageStatus.saving));

    try {
      await _saveAsZipUseCase(
        images: state.generatedImages!,
        destinationPath: filePath,
        rotations: state.imageRotations,
      );
      emit(
        state.copyWith(
          status: PdfToImageStatus.savedSuccess,
          successMessage: 'ZIP file saved successfully',
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
          errorMessage: 'Error saving ZIP file: $e',
        ),
      );
    }
  }

  Future<void> startConversion() async {
    log('Cubit: Starting conversion flow...');
    if (state.selectedFiles.isEmpty) return;

    await _conversionSubscription?.cancel();
    emit(state.copyWith(status: PdfToImageStatus.converting));

    final params = PdfToImageParams(
      inputFiles: state.selectedFiles,
      outputFormat: state.outputFormat,
      dpi: state.dpi,
    );

    try {
      final stream = _convertPdfToImagesUseCase(params);
      _conversionSubscription = stream.listen(
        (event) {
          if (event is PdfToImageProgress) {
            emit(state.copyWith(progress: event.progress));
          } else if (event is PdfToImageCompleted) {
            emit(
              state.copyWith(
                status: PdfToImageStatus.review,
                generatedImages: event.images,
                groupedImages: event.groupedImages,
                progress: null,
              ),
            );
          }
        },
        onError: (error) {
          emit(
            state.copyWith(
              status: PdfToImageStatus.error,
              errorMessage: 'Error converting PDF to images: $error',
            ),
          );
        },
      );
    } catch (e) {
      log('Error initiating conversion: $e');
      emit(
        state.copyWith(
          status: PdfToImageStatus.error,
          errorMessage: 'Error converting PDF to images',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _conversionSubscription?.cancel();
    return super.close();
  }

  void reset() {
    emit(state.copyWith(status: PdfToImageStatus.initial));
  }
}
