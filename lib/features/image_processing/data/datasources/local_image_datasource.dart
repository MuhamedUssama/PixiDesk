import 'dart:io';

import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';

abstract class LocalImageDataSource {
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
