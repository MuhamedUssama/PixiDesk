import 'dart:io';
import 'package:injectable/injectable.dart';

import '../repositories/pdf_to_image_repository.dart';

@injectable
class SaveAsZipUseCase {
  final PdfToImageRepository repository;

  SaveAsZipUseCase(this.repository);

  Future<void> call({
    required List<File> images,
    required String destinationPath,
    Map<String, int>? rotations,
  }) async {
    return repository.saveAsZip(images, destinationPath, rotations: rotations);
  }
}
