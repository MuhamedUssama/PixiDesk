import 'dart:math' as math;
import 'image_entity.dart';
import 'image_failure.dart';
import 'image_format.dart';
import 'image_recipe.dart';

class ImageGeometry {
  final int width, height;
  const ImageGeometry(this.width, this.height);
  static ImageGeometry plan(ImageEntity source, ImageRecipe recipe) {
    var w = math.max(1, (source.width * recipe.cropWidth).floor());
    var h = math.max(1, (source.height * recipe.cropHeight).floor());
    if (recipe.width != null || recipe.height != null) {
      var width = recipe.width ?? (w * recipe.height! / h).round();
      var height = recipe.height ?? (h * recipe.width! / w).round();
      if (recipe.resizeMode == ResizeMode.fit) {
        var scale = math.min(width / w, height / h);
        if (!recipe.allowUpscale) scale = math.min(1, scale);
        width = math.max(1, (w * scale).round());
        height = math.max(1, (h * scale).round());
      } else if (!recipe.allowUpscale) {
        final scale = math.min(1.0, math.min(w / width, h / height));
        width = math.max(1, (width * scale).round());
        height = math.max(1, (height * scale).round());
      }
      w = width;
      h = height;
    }
    if (recipe.quarterTurns.isOdd) {
      final oldWidth = w;
      w = h;
      h = oldWidth;
    }
    if (recipe.format == ImageFormat.ico) {
      w = recipe.iconPack ? 16 : 256;
      h = w;
    }
    if (w * h > 24000000) {
      throw const ImageFailure(ImageFailureCode.resourceLimit);
    }
    return ImageGeometry(w, h);
  }

  static List<ImageRecipe> assetScales(ImageEntity source, ImageRecipe recipe) {
    final width = recipe.width ?? (source.width * recipe.cropWidth / 3).floor();
    final height =
        recipe.height ??
        (width *
                source.height *
                recipe.cropHeight /
                (source.width * recipe.cropWidth))
            .round();
    if (width < 1 ||
        height < 1 ||
        width * 3 > source.width * recipe.cropWidth ||
        height * 3 > source.height * recipe.cropHeight) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    return List.generate(
      3,
      (index) => recipe.copyWith(
        format: ImageFormat.png,
        clearTarget: true,
        width: width * (index + 1),
        height: height * (index + 1),
        allowUpscale: false,
      ),
    );
  }
}
