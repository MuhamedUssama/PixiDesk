import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';

@injectable
class SaveImagesUseCase {
  final PdfToImageRepository _repository;

  SaveImagesUseCase(this._repository);

  Future<void> call(
    List<File> images,
    String destinationPath,
    Map<String, int> rotations,
  ) {
    return _repository.saveImages(
      images,
      destinationPath,
      rotations: rotations,
    );
  }
}
