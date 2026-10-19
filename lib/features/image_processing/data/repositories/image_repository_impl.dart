import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/local_image_datasource.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final LocalImageDataSource _source;
  ImageRepositoryImpl(this._source);
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ImageFailure {
      rethrow;
    } on FileSystemException catch (e) {
      throw ImageFailure(
        e.osError?.errorCode == 13 || e.osError?.errorCode == 1
            ? ImageFailureCode.permissionDenied
            : ImageFailureCode.invalidInput,
        e,
      );
    } catch (e) {
      throw ImageFailure(ImageFailureCode.encodeFailed, e);
    }
  }

  @override
  Future<ImageEntity> inspect(String path, ImageCancellation cancellation) =>
      _guard(() => _source.inspect(path, cancellation));
  @override
  Future<ImageResult> process(
    ImageRequest request,
    ImageCancellation cancellation,
  ) => _guard(() => _source.process(request, cancellation));
  @override
  Future<Uint8List> preview(
    ImageEntity source,
    ImageRecipe recipe,
    ImageCancellation cancellation,
  ) => _guard(() => _source.preview(source, recipe, cancellation));
}
