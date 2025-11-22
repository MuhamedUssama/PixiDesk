import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/usecases/compress_image_usecase.dart';
import '../../domain/usecases/convert_image_usecase.dart';
import 'image_state.dart';

@injectable
class ImageCubit extends Cubit<ImageState> {
  final ConvertImageUseCase _convertImageUseCase;
  final CompressImageUseCase _compressImageUseCase;

  ImageCubit(this._convertImageUseCase, this._compressImageUseCase)
    : super(const ImageState());

  void selectImage(File file) {
    emit(
      state.copyWith(
        selectedImage: ImageEntity.fromFile(file),
        status: ImageStatus.initial,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  void setTargetFormat(ImageFormat format) {
    emit(state.copyWith(targetFormat: format));
  }

  void setQuality(int quality) {
    emit(state.copyWith(quality: quality));
  }

  Future<void> convertImage() async {
    if (state.selectedImage == null || state.targetFormat == null) return;

    emit(state.copyWith(status: ImageStatus.loading));

    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Converted Image',
        fileName:
            '${state.selectedImage!.name.split('.').first}.${state.targetFormat!.extension}',
        allowedExtensions: [state.targetFormat!.extension],
        type: FileType.custom,
      );

      if (savePath == null) {
        emit(state.copyWith(status: ImageStatus.initial));
        return;
      }

      await _convertImageUseCase(
        image: state.selectedImage!.file,
        targetFormat: state.targetFormat!,
        destinationPath: savePath,
      );

      emit(
        state.copyWith(
          status: ImageStatus.success,
          successMessage: 'Image converted successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ImageStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> compressImage() async {
    if (state.selectedImage == null) return;

    emit(state.copyWith(status: ImageStatus.loading));

    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Compressed Image',
        fileName: 'compressed_${state.selectedImage!.name}',
        allowedExtensions: [state.selectedImage!.format.extension],
        type: FileType.custom,
      );

      if (savePath == null) {
        emit(state.copyWith(status: ImageStatus.initial));
        return;
      }

      await _compressImageUseCase(
        image: state.selectedImage!.file,
        quality: state.quality,
        destinationPath: savePath,
      );

      emit(
        state.copyWith(
          status: ImageStatus.success,
          successMessage: 'Image compressed successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ImageStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      selectImage(File(result.files.single.path!));
    }
  }
}
