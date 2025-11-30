import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';

@injectable
class SaveAsSeparateZipsUseCase {
  final PdfToImageRepository repository;

  SaveAsSeparateZipsUseCase(this.repository);

  Future<void> call({
    required Map<String, List<File>> groupedImages,
    required String destinationDirectory,
    Map<String, int>? rotations,
  }) async {
    return repository.saveAsSeparateZips(
      groupedImages,
      destinationDirectory,
      rotations: rotations,
    );
  }
}
