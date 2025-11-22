import 'dart:io';
import 'image_format.dart';

class ImageEntity {
  final File file;
  final String name;
  final String path;
  final int sizeInBytes;
  final ImageFormat format;

  ImageEntity({
    required this.file,
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.format,
  });

  factory ImageEntity.fromFile(File file) {
    return ImageEntity(
      file: file,
      name: file.uri.pathSegments.last,
      path: file.path,
      sizeInBytes: file.lengthSync(),
      format: ImageFormat.fromPath(file.path),
    );
  }
}
