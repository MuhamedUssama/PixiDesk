import 'dart:io';
import '../entities/image_format.dart';

abstract class ImageRepository {
  Future<File> convertImage({
    required File image,
    required ImageFormat targetFormat,
    required String destinationPath,
  });

  Future<File> compressImage({
    required File image,
    required int quality,
    required String destinationPath,
  });
}
