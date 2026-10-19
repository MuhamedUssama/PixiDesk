import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_recipe.dart';
import '../../domain/entities/image_job.dart';

const maxImageBytes = 64 * 1024 * 1024;
const maxImagePixels = 24000000;
const maxTotalPixels = 32000000;

class ImageWorkerTask {
  final String path;
  final ImageRecipe? recipe;
  final Uint8List? textWatermark;
  const ImageWorkerTask(this.path, {this.recipe, this.textWatermark});
}

class EncodedImage {
  final Uint8List bytes, thumbnail;
  final int width, height;
  final List<ImageNotice> notices;
  const EncodedImage(
    this.bytes,
    this.thumbnail,
    this.width,
    this.height,
    this.notices,
  );
}

/// A killable isolate per item bounds concurrency and makes Cancel meaningful.
Future<T> runImageWorker<T>(
  ImageWorkerTask task,
  ImageCancellation token,
) async {
  token.check();
  final port = ReceivePort();
  final isolate = await Isolate.spawn(
    _workerMain,
    [port.sendPort, task],
    onError: port.sendPort,
    errorsAreFatal: true,
  );
  final response = Completer<Object?>();
  final subscription = port.listen((message) {
    if (!response.isCompleted) response.complete(message);
  });
  final detach = token.onCancel(() {
    if (!response.isCompleted) {
      response.completeError(const ImageFailure(ImageFailureCode.cancelled));
    }
  });
  try {
    final message = await response.future;
    token.check();
    if (message is List && message.length == 2 && message[0] == 'ok') {
      return message[1] as T;
    }
    if (message is List && message.length == 2 && message[0] == 'failure') {
      throw ImageFailure(ImageFailureCode.values[message[1] as int]);
    }
    throw const ImageFailure(ImageFailureCode.encodeFailed);
  } finally {
    detach();
    isolate.kill(priority: Isolate.immediate);
    port.close();
    await subscription.cancel();
  }
}

void _workerMain(List<Object> args) async {
  final port = args[0] as SendPort;
  final task = args[1] as ImageWorkerTask;
  img.Decoder.defaultMaxPixels = maxTotalPixels;
  try {
    final result = task.recipe == null
        ? await inspectImage(task.path)
        : await renderImage(task);
    port.send(['ok', result]);
  } on ImageFailure catch (e) {
    port.send(['failure', e.code.index]);
  } on FileSystemException catch (e) {
    port.send([
      'failure',
      (e.osError?.errorCode == 13 || e.osError?.errorCode == 1
              ? ImageFailureCode.permissionDenied
              : ImageFailureCode.invalidInput)
          .index,
    ]);
  } catch (_) {
    port.send(['failure', ImageFailureCode.invalidInput.index]);
  }
}

Future<(Uint8List, img.Decoder, img.DecodeInfo)> _read(String path) async {
  final file = File(path);
  final stat = await file.stat();
  if (stat.type != FileSystemEntityType.file || stat.size == 0) {
    throw const ImageFailure(ImageFailureCode.invalidInput);
  }
  if (stat.size > maxImageBytes) {
    throw const ImageFailure(ImageFailureCode.resourceLimit);
  }
  final bytes = await file.readAsBytes();
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (decoder == null || info == null) {
    throw const ImageFailure(ImageFailureCode.unsupportedFormat);
  }
  if (info.width < 1 ||
      info.height < 1 ||
      info.numFrames < 1 ||
      info.width * info.height > maxImagePixels ||
      info.numFrames > 120 ||
      info.width * info.height * info.numFrames > maxTotalPixels) {
    throw const ImageFailure(ImageFailureCode.resourceLimit);
  }
  return (bytes, decoder, info);
}

Uint8List _thumbnail(img.Image image) {
  final frame = img.Image.from(image.frames.first, noAnimation: true);
  final scale = math.min(1.0, 1000 / math.max(frame.width, frame.height));
  return img.encodePng(
    scale < 1
        ? img.copyResize(
            frame,
            width: math.max(1, (frame.width * scale).round()),
            height: math.max(1, (frame.height * scale).round()),
            interpolation: img.Interpolation.average,
          )
        : frame,
  );
}

Future<ImageEntity> inspectImage(String path) async {
  final (bytes, decoder, info) = await _read(path);
  final first = decoder.decodeFrame(0);
  if (first == null) throw const ImageFailure(ImageFailureCode.invalidInput);
  final image = img.bakeOrientation(first);
  final stat = await File(path).stat();
  final format = ImageFormat.fromPath('asset.${decoder.format.name}');
  // Read-only codecs may be imported; export uses an explicit supported target.
  return ImageEntity(
    path: p.normalize(p.absolute(path)),
    name: p.basename(path),
    sizeInBytes: bytes.length,
    format: format,
    width: image.width,
    height: image.height,
    frames: info.numFrames,
    modifiedMicros: stat.modified.microsecondsSinceEpoch,
    hasAlpha: first.hasAlpha,
    hasExif: first.hasExif,
    hasIccProfile: first.iccProfile != null,
    thumbnail: _thumbnail(image),
  );
}

img.ColorRgb8 _background(int rgb) =>
    img.ColorRgb8((rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);

img.Image _resize(img.Image image, ImageRecipe recipe) {
  if (recipe.width == null && recipe.height == null) return image;
  var width =
      recipe.width ?? (image.width * recipe.height! / image.height).round();
  var height =
      recipe.height ?? (image.height * recipe.width! / image.width).round();
  if (recipe.resizeMode == ResizeMode.fit) {
    var scale = math.min(width / image.width, height / image.height);
    if (!recipe.allowUpscale) scale = math.min(1, scale);
    width = math.max(1, (image.width * scale).round());
    height = math.max(1, (image.height * scale).round());
  } else if (!recipe.allowUpscale) {
    final scale = math.min(
      1.0,
      math.min(image.width / width, image.height / height),
    );
    width = math.max(1, (width * scale).round());
    height = math.max(1, (height * scale).round());
  }
  if (width * height > maxImagePixels) {
    throw const ImageFailure(ImageFailureCode.resourceLimit);
  }
  if (recipe.resizeMode == ResizeMode.fill) {
    final ratio = width / height;
    final cropW = math.min(image.width, (image.height * ratio).round());
    final cropH = math.min(image.height, (image.width / ratio).round());
    image = img.copyCrop(
      image,
      x: (image.width - cropW) ~/ 2,
      y: (image.height - cropH) ~/ 2,
      width: math.max(1, cropW),
      height: math.max(1, cropH),
    );
  }
  return img.copyResize(
    image,
    width: width,
    height: height,
    interpolation: img.Interpolation.average,
  );
}

img.Image _transform(
  img.Image source,
  ImageRecipe recipe,
  List<img.Image> watermarks,
) {
  var frame = img
      .bakeOrientation(img.Image.from(source, noAnimation: true))
      .convert(numChannels: 4);
  if (recipe.cropLeft != 0 ||
      recipe.cropTop != 0 ||
      recipe.cropWidth != 1 ||
      recipe.cropHeight != 1) {
    frame = img.copyCrop(
      frame,
      x: (frame.width * recipe.cropLeft).floor(),
      y: (frame.height * recipe.cropTop).floor(),
      width: math.max(1, (frame.width * recipe.cropWidth).floor()),
      height: math.max(1, (frame.height * recipe.cropHeight).floor()),
    );
  }
  frame = _resize(frame, recipe);
  if (recipe.quarterTurns != 0) {
    frame = img.copyRotate(frame, angle: 90 * recipe.quarterTurns);
  }
  if (recipe.flipHorizontal) frame = img.flipHorizontal(frame);
  if (recipe.flipVertical) frame = img.flipVertical(frame);
  if (recipe.brightness != 1 ||
      recipe.contrast != 1 ||
      recipe.saturation != 1) {
    img.adjustColor(
      frame,
      brightness: recipe.brightness,
      contrast: recipe.contrast,
      saturation: recipe.saturation,
    );
  }
  if (recipe.grayscale) img.grayscale(frame);
  for (final mark in watermarks) {
    final maxWidth = math.max(1, (frame.width * recipe.watermarkScale).round());
    final maxHeight = math.max(
      1,
      (frame.height * recipe.watermarkScale).round(),
    );
    final scale = math.min(maxWidth / mark.width, maxHeight / mark.height);
    final overlay = img
        .copyResize(
          mark,
          width: math.max(1, (mark.width * scale).round()),
          height: math.max(1, (mark.height * scale).round()),
        )
        .convert(numChannels: 4);
    for (final pixel in overlay) {
      pixel.a = (pixel.a * recipe.watermarkOpacity).round();
    }
    final column = recipe.watermarkAnchor.index % 3;
    final row = recipe.watermarkAnchor.index ~/ 3;
    final pad = (math.min(frame.width, frame.height) * .025).round();
    final x = column == 0
        ? pad
        : column == 1
        ? (frame.width - overlay.width) ~/ 2
        : frame.width - overlay.width - pad;
    final y = row == 0
        ? pad
        : row == 1
        ? (frame.height - overlay.height) ~/ 2
        : frame.height - overlay.height - pad;
    img.compositeImage(frame, overlay, dstX: x, dstY: y);
  }
  // Pixel orientation has already been baked; never copy the old orientation tag.
  if (recipe.metadata == MetadataPolicy.remove) {
    frame.exif = img.ExifData();
    frame.textData = null;
    // Retain ICC to avoid silently changing the meaning of pixel colors.
  } else {
    frame.exif.imageIfd.orientation = 1;
  }
  frame.frameDuration = source.frameDuration;
  return frame;
}

Uint8List _encode(img.Image image, ImageRecipe recipe, int quality) {
  switch (recipe.format.canonical) {
    case ImageFormat.png:
      return img.encodePng(image, level: 9);
    case ImageFormat.jpg:
      return img.encodeJpg(image, quality: quality);
    case ImageFormat.webp:
      return img.encodeWebP(
        image,
        lossless: recipe.webpLossless,
        quality: quality,
      );
    case ImageFormat.bmp:
      return img.encodeBmp(image);
    case ImageFormat.tiff:
      return img.encodeTiff(image);
    case ImageFormat.gif:
      return img.encodeGif(image);
    case ImageFormat.ico:
      final sizes = recipe.iconPack ? [16, 32, 48, 64, 128, 256] : [256];
      return img.IcoEncoder().encodeImages(
        sizes
            .map(
              (size) => img.copyResize(
                image.frames.first,
                width: size,
                height: size,
                maintainAspect: true,
                backgroundColor: img.ColorRgba8(0, 0, 0, 0),
                interpolation: img.Interpolation.average,
              ),
            )
            .toList(),
      );
    case ImageFormat.jpeg:
    case ImageFormat.unknown:
      throw const ImageFailure(ImageFailureCode.unsupportedFormat);
  }
}

Future<EncodedImage> renderImage(ImageWorkerTask task) async {
  final recipe = task.recipe!;
  recipe.validate();
  final (bytes, decoder, info) = await _read(task.path);
  final notices = <ImageNotice>[];
  final preserveFrames =
      recipe.animation == AnimationPolicy.preserve &&
      recipe.format.supportsAnimation;
  if (info.numFrames > 1 && !preserveFrames) {
    notices.add(ImageNotice.animationFlattened);
  }
  final decoded = decoder.decode(bytes, frame: preserveFrames ? null : 0);
  if (decoded == null) throw const ImageFailure(ImageFailureCode.invalidInput);
  if (decoded.hasAlpha && !recipe.format.supportsAlpha) {
    notices.add(ImageNotice.alphaFlattened);
  }
  if (recipe.metadata == MetadataPolicy.preserve &&
      ![
        ImageFormat.png,
        ImageFormat.jpg,
        ImageFormat.webp,
        ImageFormat.tiff,
      ].contains(recipe.format.canonical)) {
    notices.add(ImageNotice.metadataLimited);
  }
  final watermarks = <img.Image>[];
  if (task.textWatermark != null) {
    watermarks.add(img.decodePng(task.textWatermark!)!);
  }
  if (recipe.watermarkPath != null) {
    final (markBytes, markDecoder, _) = await _read(recipe.watermarkPath!);
    final mark = markDecoder.decode(markBytes, frame: 0);
    if (mark == null) throw const ImageFailure(ImageFailureCode.invalidInput);
    watermarks.add(img.bakeOrientation(mark));
  }
  img.Image? output;
  var outputPixels = 0;
  for (final frame in decoded.frames) {
    var transformed = _transform(frame, recipe, watermarks);
    outputPixels += transformed.width * transformed.height;
    if (outputPixels > maxTotalPixels ||
        transformed.width * transformed.height * decoded.numFrames >
            maxTotalPixels) {
      throw const ImageFailure(ImageFailureCode.resourceLimit);
    }
    if (!recipe.format.supportsAlpha) {
      final flat = img.Image(
        width: transformed.width,
        height: transformed.height,
        numChannels: 3,
      );
      img.fill(flat, color: _background(recipe.backgroundRgb));
      img.compositeImage(flat, transformed);
      flat.frameDuration = transformed.frameDuration;
      flat.exif = transformed.exif;
      flat.iccProfile = transformed.iccProfile;
      transformed = flat;
    }
    if (output == null) {
      output = transformed;
      output.loopCount = decoded.loopCount;
    } else {
      output.addFrame(transformed);
    }
  }
  var encoded = _encode(output!, recipe, recipe.quality);
  if (recipe.targetBytes != null && encoded.length > recipe.targetBytes!) {
    var low = recipe.minQuality, high = recipe.quality - 1;
    Uint8List? feasible;
    for (var attempt = 0; attempt < 7 && low <= high; attempt++) {
      final q = (low + high) ~/ 2;
      final candidate = _encode(output, recipe, q);
      if (candidate.length < encoded.length) encoded = candidate;
      if (candidate.length <= recipe.targetBytes!) {
        feasible = candidate;
        low = q + 1;
      } else {
        high = q - 1;
      }
    }
    encoded = feasible ?? encoded;
    if (encoded.length > recipe.targetBytes!) {
      notices.add(ImageNotice.targetNotReached);
    }
  }
  // Preview the encoded output, including lossy artifacts, not the source pixels.
  final check = img.decodeImage(encoded, frame: 0);
  if (check == null) throw const ImageFailure(ImageFailureCode.encodeFailed);
  return EncodedImage(
    encoded,
    _thumbnail(check),
    check.width,
    check.height,
    notices,
  );
}
