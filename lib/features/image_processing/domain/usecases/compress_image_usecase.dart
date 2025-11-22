import 'dart:io';
import 'package:injectable/injectable.dart';
import '../repositories/image_repository.dart';

@lazySingleton
class CompressImageUseCase {
  final ImageRepository _repository;

  CompressImageUseCase(this._repository);

  Future<File> call({
    required File image,
    required int quality,
    required String destinationPath,
  }) {
    return _repository.compressImage(
      image: image,
      quality: quality,
      destinationPath: destinationPath,
    );
  }
}
