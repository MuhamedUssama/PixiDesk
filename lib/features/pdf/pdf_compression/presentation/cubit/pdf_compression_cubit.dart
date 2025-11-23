import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/usecases/compress_pdf_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';

@injectable
class PdfCompressionCubit extends Cubit<PdfCompressionState> {
  final CompressPdfUseCase _compressPdfUseCase;

  PdfCompressionCubit(this._compressPdfUseCase)
    : super(const PdfCompressionState());

  void selectFile(File file) {
    emit(
      state.copyWith(
        selectedFile: file,
        status: PdfCompressionStatus.initial,
        compressedFile: null,
        errorMessage: null,
      ),
    );
  }

  void changeCompressionLevel(CompressionLevel level) {
    emit(state.copyWith(compressionLevel: level));
  }

  void clearFile() {
    emit(const PdfCompressionState());
  }

  Future<void> compressPdf(String outputPath) async {
    if (state.selectedFile == null) return;

    emit(state.copyWith(status: PdfCompressionStatus.loading));

    try {
      final compressedFile = await _compressPdfUseCase(
        input: state.selectedFile!,
        outputPath: outputPath,
        level: state.compressionLevel,
      );

      emit(
        state.copyWith(
          status: PdfCompressionStatus.success,
          compressedFile: compressedFile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PdfCompressionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
