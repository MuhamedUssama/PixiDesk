import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../entities/image_entity.dart';
import '../entities/image_failure.dart';
import '../entities/image_recipe.dart';
import '../repositories/image_repository.dart';

@lazySingleton
class PreviewImageUseCase {
  final ImageRepository _repository;
  PreviewImageUseCase(this._repository);
  Future<Uint8List> call(
    ImageEntity source,
    ImageRecipe recipe,
    ImageCancellation token,
  ) {
    recipe.validate();
    return _repository.preview(source, recipe, token);
  }
}
