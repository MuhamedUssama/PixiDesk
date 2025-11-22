import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/image_format.dart';
import '../repositories/image_repository.dart';

@lazySingleton
class ConvertImageUseCase {
  final ImageRepository _repository;

  ConvertImageUseCase(this._repository);

  Future<File> call({
    required File image,
    required ImageFormat targetFormat,
    required String destinationPath,
  }) {
    return _repository.convertImage(
      image: image,
      targetFormat: targetFormat,
      destinationPath: destinationPath,
    );
  }
}
