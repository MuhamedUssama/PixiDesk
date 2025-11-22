import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/image_processing/data/datasources/local_image_datasource.dart';
import '../../domain/entities/image_format.dart';

class ImageProcessingParams {
  final List<int> imageBytes;
  final ImageFormat targetFormat;
  final int quality;

  ImageProcessingParams({
    required this.imageBytes,
    required this.targetFormat,
    this.quality = 100,
  });
}

Future<List<int>> processImageInIsolate(ImageProcessingParams params) async {
  final decodedImage = img.decodeImage(Uint8List.fromList(params.imageBytes));

  if (decodedImage == null) {
    throw Exception('Failed to decode image');
  }

  List<int> encodedBytes;
  switch (params.targetFormat) {
    case ImageFormat.png:
      encodedBytes = img.encodePng(decodedImage);
      break;
    case ImageFormat.jpg:
    case ImageFormat.jpeg:
      encodedBytes = img.encodeJpg(decodedImage, quality: params.quality);
      break;
    case ImageFormat.webp:
      throw Exception(
        'WebP encoding is not supported by the fallback encoder.',
      );
    case ImageFormat.bmp:
      encodedBytes = img.encodeBmp(decodedImage);
      break;
    case ImageFormat.tiff:
      encodedBytes = img.encodeTiff(decodedImage);
      break;
    case ImageFormat.ico:
      encodedBytes = img.encodeIco(decodedImage);
      break;
    case ImageFormat.gif:
      encodedBytes = img.encodeGif(decodedImage);
      break;
  }
  return encodedBytes;
}

@LazySingleton(as: LocalImageDataSource)
class LocalImageDataSourceImpl implements LocalImageDataSource {
  @override
  Future<File> convertImage({
    required File image,
    required ImageFormat targetFormat,
    required String destinationPath,
  }) async {
    final bytes = await image.readAsBytes();

    final encodedBytes = await compute(
      processImageInIsolate,
      ImageProcessingParams(imageBytes: bytes, targetFormat: targetFormat),
    );

    final newFile = File(destinationPath);
    await newFile.writeAsBytes(encodedBytes);
    return newFile;
  }

  @override
  Future<File> compressImage({
    required File image,
    required int quality,
    required String destinationPath,
  }) async {
    // Try using flutter_image_compress first
    try {
      final format = ImageFormat.fromPath(image.path);
      CompressFormat compressFormat;

      switch (format) {
        case ImageFormat.jpg:
        case ImageFormat.jpeg:
          compressFormat = CompressFormat.jpeg;
          break;
        case ImageFormat.png:
          compressFormat = CompressFormat.png;
          break;
        case ImageFormat.webp:
          compressFormat = CompressFormat.webp;
          break;
        default:
          // For other formats, use image package
          return _compressWithImagePackage(image, quality, destinationPath);
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        destinationPath,
        quality: quality,
        format: compressFormat,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final originalSize = await image.length();
        final compressedSize = await compressedFile.length();

        if (compressedSize >= originalSize) {
          await image.copy(destinationPath);
          return File(destinationPath);
        }
        return compressedFile;
      } else {
        return _compressWithImagePackage(image, quality, destinationPath);
      }
    } catch (e) {
      // Fallback to image package
      return _compressWithImagePackage(image, quality, destinationPath);
    }
  }

  Future<File> _compressWithImagePackage(
    File image,
    int quality,
    String destinationPath,
  ) async {
    final bytes = await image.readAsBytes();
    final format = ImageFormat.fromPath(destinationPath);

    final encodedBytes = await compute(
      processImageInIsolate,
      ImageProcessingParams(
        imageBytes: bytes,
        targetFormat: format,
        quality: quality,
      ),
    );

    final newFile = File(destinationPath);
    await newFile.writeAsBytes(encodedBytes);
    return newFile;
  }
}
