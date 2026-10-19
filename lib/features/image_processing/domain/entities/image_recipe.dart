import 'package:equatable/equatable.dart';
import 'image_format.dart';
import 'image_failure.dart';

enum ResizeMode { fit, fill, stretch }

enum MetadataPolicy { remove, preserve }

enum AnimationPolicy { preserve, firstFrame }

enum OutputConflict { rename, skip, replace }

enum WatermarkAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class ImageRecipe extends Equatable {
  final ImageFormat format;
  final int quality;
  final int? targetBytes;
  final int minQuality;
  final int? width;
  final int? height;
  final ResizeMode resizeMode;
  final bool allowUpscale;
  final double cropLeft, cropTop, cropWidth, cropHeight;
  final int quarterTurns;
  final bool flipHorizontal, flipVertical;
  final double brightness, contrast, saturation;
  final bool grayscale;
  final MetadataPolicy metadata;
  final AnimationPolicy animation;
  final int backgroundRgb;
  final bool webpLossless;
  final bool iconPack;
  final String watermarkText;
  final String? watermarkPath;
  final double watermarkOpacity, watermarkScale;
  final WatermarkAnchor watermarkAnchor;

  const ImageRecipe({
    this.format = ImageFormat.png,
    this.quality = 80,
    this.targetBytes,
    this.minQuality = 35,
    this.width,
    this.height,
    this.resizeMode = ResizeMode.fit,
    this.allowUpscale = false,
    this.cropLeft = 0,
    this.cropTop = 0,
    this.cropWidth = 1,
    this.cropHeight = 1,
    this.quarterTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.brightness = 1,
    this.contrast = 1,
    this.saturation = 1,
    this.grayscale = false,
    this.metadata = MetadataPolicy.remove,
    this.animation = AnimationPolicy.preserve,
    this.backgroundRgb = 0xffffff,
    this.webpLossless = false,
    this.iconPack = true,
    this.watermarkText = '',
    this.watermarkPath,
    this.watermarkOpacity = .65,
    this.watermarkScale = .2,
    this.watermarkAnchor = WatermarkAnchor.bottomRight,
  });

  void validate() {
    final numbers = [
      cropLeft,
      cropTop,
      cropWidth,
      cropHeight,
      brightness,
      contrast,
      saturation,
      watermarkOpacity,
      watermarkScale,
    ];
    if (!numbers.every((n) => n.isFinite) ||
        !ImageFormat.outputFormats.contains(format.canonical) ||
        quality < 1 ||
        quality > 100 ||
        minQuality < 1 ||
        minQuality > quality ||
        (targetBytes != null &&
            (targetBytes! < 1024 ||
                !format.supportsQuality ||
                (format == ImageFormat.webp && webpLossless))) ||
        (width != null && (width! < 1 || width! > 16000)) ||
        (height != null && (height! < 1 || height! > 16000)) ||
        (width ?? 1) * (height ?? 1) > 24000000 ||
        cropLeft < 0 ||
        cropTop < 0 ||
        cropWidth <= 0 ||
        cropHeight <= 0 ||
        cropLeft + cropWidth > 1.000001 ||
        cropTop + cropHeight > 1.000001 ||
        quarterTurns < 0 ||
        quarterTurns > 3 ||
        brightness < 0 ||
        brightness > 2 ||
        contrast < 0 ||
        contrast > 2 ||
        saturation < 0 ||
        saturation > 2 ||
        watermarkOpacity < 0 ||
        watermarkOpacity > 1 ||
        watermarkScale <= 0 ||
        watermarkScale > 1 ||
        watermarkText.length > 500 ||
        backgroundRgb < 0 ||
        backgroundRgb > 0xffffff) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
  }

  /// Explicit clearing avoids nullable copyWith values silently retaining settings.
  ImageRecipe copyWith({
    ImageFormat? format,
    int? quality,
    int? targetBytes,
    int? minQuality,
    int? width,
    int? height,
    bool clearTarget = false,
    bool clearWidth = false,
    bool clearHeight = false,
    ResizeMode? resizeMode,
    bool? allowUpscale,
    double? cropLeft,
    double? cropTop,
    double? cropWidth,
    double? cropHeight,
    int? quarterTurns,
    bool? flipHorizontal,
    bool? flipVertical,
    double? brightness,
    double? contrast,
    double? saturation,
    bool? grayscale,
    MetadataPolicy? metadata,
    AnimationPolicy? animation,
    int? backgroundRgb,
    bool? webpLossless,
    bool? iconPack,
    String? watermarkText,
    String? watermarkPath,
    bool clearWatermark = false,
    double? watermarkOpacity,
    double? watermarkScale,
    WatermarkAnchor? watermarkAnchor,
  }) => ImageRecipe(
    format: format ?? this.format,
    quality: quality ?? this.quality,
    targetBytes: clearTarget ? null : targetBytes ?? this.targetBytes,
    minQuality: minQuality ?? this.minQuality,
    width: clearWidth ? null : width ?? this.width,
    height: clearHeight ? null : height ?? this.height,
    resizeMode: resizeMode ?? this.resizeMode,
    allowUpscale: allowUpscale ?? this.allowUpscale,
    cropLeft: cropLeft ?? this.cropLeft,
    cropTop: cropTop ?? this.cropTop,
    cropWidth: cropWidth ?? this.cropWidth,
    cropHeight: cropHeight ?? this.cropHeight,
    quarterTurns: quarterTurns ?? this.quarterTurns,
    flipHorizontal: flipHorizontal ?? this.flipHorizontal,
    flipVertical: flipVertical ?? this.flipVertical,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
    grayscale: grayscale ?? this.grayscale,
    metadata: metadata ?? this.metadata,
    animation: animation ?? this.animation,
    backgroundRgb: backgroundRgb ?? this.backgroundRgb,
    webpLossless: webpLossless ?? this.webpLossless,
    iconPack: iconPack ?? this.iconPack,
    watermarkText: watermarkText ?? this.watermarkText,
    watermarkPath: clearWatermark ? null : watermarkPath ?? this.watermarkPath,
    watermarkOpacity: watermarkOpacity ?? this.watermarkOpacity,
    watermarkScale: watermarkScale ?? this.watermarkScale,
    watermarkAnchor: watermarkAnchor ?? this.watermarkAnchor,
  );

  @override
  List<Object?> get props => [
    format,
    quality,
    targetBytes,
    minQuality,
    width,
    height,
    resizeMode,
    allowUpscale,
    cropLeft,
    cropTop,
    cropWidth,
    cropHeight,
    quarterTurns,
    flipHorizontal,
    flipVertical,
    brightness,
    contrast,
    saturation,
    grayscale,
    metadata,
    animation,
    backgroundRgb,
    webpLossless,
    iconPack,
    watermarkText,
    watermarkPath,
    watermarkOpacity,
    watermarkScale,
    watermarkAnchor,
  ];
}
