import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';

@injectable
class PdfToImageCubit extends Cubit<PdfToImageState> {
  final ConvertPdfToImagesUseCase _convertPdfToImagesUseCase;

  PdfToImageCubit(this._convertPdfToImagesUseCase)
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
