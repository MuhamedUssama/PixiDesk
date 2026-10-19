import 'dart:convert';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';

/// Versioned persistence DTOs stay outside the domain.
class ImageWorkspaceCodec {
  static Map<String, Object?> recipe(ImageRecipe r) => {
    'format': r.format.canonical.name,
    'quality': r.quality,
    'targetBytes': r.targetBytes,
    'minQuality': r.minQuality,
    'width': r.width,
    'height': r.height,
    'resizeMode': r.resizeMode.name,
    'allowUpscale': r.allowUpscale,
    'cropLeft': r.cropLeft,
    'cropTop': r.cropTop,
    'cropWidth': r.cropWidth,
    'cropHeight': r.cropHeight,
    'quarterTurns': r.quarterTurns,
    'flipHorizontal': r.flipHorizontal,
    'flipVertical': r.flipVertical,
    'brightness': r.brightness,
    'contrast': r.contrast,
    'saturation': r.saturation,
    'grayscale': r.grayscale,
    'metadata': r.metadata.name,
    'animation': r.animation.name,
    'backgroundRgb': r.backgroundRgb,
    'webpLossless': r.webpLossless,
    'iconPack': r.iconPack,
    'watermarkText': r.watermarkText,
    'watermarkPath': r.watermarkPath,
    'watermarkOpacity': r.watermarkOpacity,
    'watermarkScale': r.watermarkScale,
    'watermarkAnchor': r.watermarkAnchor.name,
  };

  static ImageRecipe readRecipe(Map<String, dynamic> j) {
    final r = ImageRecipe(
      format: ImageFormat.values.byName(j['format'] as String).canonical,
      quality: j['quality'] as int,
      targetBytes: j['targetBytes'] as int?,
      minQuality: j['minQuality'] as int,
      width: j['width'] as int?,
      height: j['height'] as int?,
      resizeMode: ResizeMode.values.byName(j['resizeMode'] as String),
      allowUpscale: j['allowUpscale'] as bool,
      cropLeft: (j['cropLeft'] as num).toDouble(),
      cropTop: (j['cropTop'] as num).toDouble(),
      cropWidth: (j['cropWidth'] as num).toDouble(),
      cropHeight: (j['cropHeight'] as num).toDouble(),
      quarterTurns: j['quarterTurns'] as int,
      flipHorizontal: j['flipHorizontal'] as bool,
      flipVertical: j['flipVertical'] as bool,
      brightness: (j['brightness'] as num).toDouble(),
      contrast: (j['contrast'] as num).toDouble(),
      saturation: (j['saturation'] as num).toDouble(),
      grayscale: j['grayscale'] as bool,
      metadata: MetadataPolicy.values.byName(j['metadata'] as String),
      animation: AnimationPolicy.values.byName(j['animation'] as String),
      backgroundRgb: j['backgroundRgb'] as int,
      webpLossless: j['webpLossless'] as bool,
      iconPack: j['iconPack'] as bool,
      watermarkText: j['watermarkText'] as String,
      watermarkPath: j['watermarkPath'] as String?,
      watermarkOpacity: (j['watermarkOpacity'] as num).toDouble(),
      watermarkScale: (j['watermarkScale'] as num).toDouble(),
      watermarkAnchor: WatermarkAnchor.values.byName(
        j['watermarkAnchor'] as String,
      ),
    );
    r.validate();
    return r;
  }

  static Map<String, Object?> preset(ImagePreset p) => {
    'id': p.id,
    'name': p.name,
    'recipe': recipe(p.recipe),
  };
  static ImagePreset readPreset(Map<String, dynamic> j) {
    final name = j['name'] as String;
    if (name.trim().isEmpty || name.length > 80) {
      throw const ImageFailure(ImageFailureCode.invalidPreset);
    }
    return ImagePreset(
      id: j['id'] as String,
      name: name,
      recipe: readRecipe(j['recipe'] as Map<String, dynamic>),
    );
  }

  static String exportPreset(ImagePreset p) =>
      jsonEncode({'version': 1, 'preset': preset(p)});
  static ImagePreset importPreset(String text) {
    try {
      if (text.length > 65536) throw const FormatException();
      final j = jsonDecode(text) as Map<String, dynamic>;
      if (j['version'] != 1) throw const FormatException();
      return readPreset(j['preset'] as Map<String, dynamic>);
    } catch (e) {
      throw ImageFailure(ImageFailureCode.invalidPreset, e);
    }
  }

  static Map<String, Object?> historyEntry(ImageHistoryEntry h) => {
    'id': h.id,
    'sourcePath': h.sourcePath,
    'outputPath': h.outputPath,
    'sourceBytes': h.sourceBytes,
    'sourceModifiedMicros': h.sourceModifiedMicros,
    'outputBytes': h.outputBytes,
    'createdAt': h.createdAt.toUtc().toIso8601String(),
    'recipe': recipe(h.recipe),
  };
  static ImageHistoryEntry readHistory(Map<String, dynamic> h) =>
      ImageHistoryEntry(
        id: h['id'] as String,
        sourcePath: h['sourcePath'] as String,
        outputPath: h['outputPath'] as String,
        sourceBytes: h['sourceBytes'] as int,
        sourceModifiedMicros: h['sourceModifiedMicros'] as int,
        outputBytes: h['outputBytes'] as int,
        createdAt: DateTime.parse(h['createdAt'] as String),
        recipe: readRecipe(h['recipe'] as Map<String, dynamic>),
      );
  static String encode(ImageWorkspace w) => jsonEncode({
    'version': 1,
    'presets': w.presets.map(preset).toList(),
    'history': w.history.take(200).map(historyEntry).toList(),
    'recovery': w.recovery.take(1000).map(historyEntry).toList(),
  });
  static ImageWorkspace decode(String text) {
    try {
      final j = jsonDecode(text) as Map<String, dynamic>;
      if (j['version'] != 1) throw const FormatException();
      final presets = (j['presets'] as List)
          .map((e) => readPreset(e as Map<String, dynamic>))
          .toList();
      if (presets.length > 50) throw const FormatException();
      final history = (j['history'] as List)
          .take(200)
          .map((h) => readHistory(h as Map<String, dynamic>))
          .toList();
      final recovery = (j['recovery'] as List? ?? [])
          .take(1000)
          .map((h) => readHistory(h as Map<String, dynamic>))
          .toList();
      return ImageWorkspace(
        presets: List.unmodifiable(presets),
        history: List.unmodifiable(history),
        recovery: List.unmodifiable(recovery),
      );
    } catch (e) {
      throw ImageFailure(ImageFailureCode.storageFailed, e);
    }
  }
}
