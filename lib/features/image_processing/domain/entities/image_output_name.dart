import 'image_geometry.dart';
import 'image_entity.dart';
import 'image_failure.dart';
import 'image_recipe.dart';

abstract final class ImageOutputName {
  static String build(
    String pattern,
    ImageEntity source,
    ImageRecipe recipe,
    int index,
  ) {
    final name = source.name;
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    if (pattern.trim().isEmpty ||
        pattern.length > 160 ||
        RegExp(r'[/\\\x00-\x1f]').hasMatch(pattern)) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    final geometry = ImageGeometry.plan(source, recipe);
    final tokens = RegExp(r'\{(name|index|width|height)\}');
    if (RegExp(r'[{}]').hasMatch(pattern.replaceAll(tokens, ''))) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    final values = {
      'name': stem,
      'index': (index + 1).toString().padLeft(3, '0'),
      'width': geometry.width.toString(),
      'height': geometry.height.toString(),
    };
    var output = pattern.replaceAllMapped(tokens, (match) => values[match[1]]!);
    output = output
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .replaceAll(RegExp(r'[. ]+$'), '');
    if (output.isEmpty || output == '.' || output == '..') {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    if (RegExp(
      r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])($|\.)',
      caseSensitive: false,
    ).hasMatch(output)) {
      output = '_$output';
    }
    if (output.length > 180) output = output.substring(0, 180);
    return '$output.${recipe.format.extension}';
  }
}
