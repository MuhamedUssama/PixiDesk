import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/image_processing/data/datasources/local_image_datasource.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/repositories/image_repository.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final LocalImageDataSource _dataSource;

  ImageRepositoryImpl(this._dataSource);

  @override
  Future<File> convertImage({
    required File image,
    required ImageFormat targetFormat,
    required String destinationPath,
  }) {
    return _dataSource.convertImage(
      image: image,
      targetFormat: targetFormat,
      destinationPath: destinationPath,
    );
  }

  @override
  Future<File> compressImage({
    required File image,
    required int quality,
    required String destinationPath,
  }) {
    return _dataSource.compressImage(
      image: image,
      quality: quality,
      destinationPath: destinationPath,
    );
  }
}
