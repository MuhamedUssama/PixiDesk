import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'image_format.dart';

/// An inspected snapshot. Reading files belongs to the data layer.
class ImageEntity extends Equatable {
  final String path;
  final String name;
  final int sizeInBytes;
  final ImageFormat format;
  final int width;
  final int height;
  final int frames;
  final int modifiedMicros;
  final bool hasAlpha;
  final bool hasExif;
  final bool hasIccProfile;
  final Uint8List thumbnail;

  const ImageEntity({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.format,
    required this.width,
    required this.height,
    required this.thumbnail,
    this.frames = 1,
    this.modifiedMicros = 0,
    this.hasAlpha = false,
    this.hasExif = false,
    this.hasIccProfile = false,
  });

  @override
  List<Object?> get props => [path, sizeInBytes, modifiedMicros];
}
