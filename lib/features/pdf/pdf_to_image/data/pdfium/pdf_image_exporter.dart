import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:image/image.dart' as image_codec;
import 'package:path/path.dart' as path;
import '../../../shared/domain/entities/pdf_processing_failure.dart';

enum PdfFileExportMode { images, archive, separateArchives }

class PdfFileExportRequest {
  final PdfFileExportMode mode;
  final List<String> images;
  final Map<String, List<String>> groupedImages;
  final String destination;
  final Map<String, int> rotations;
  const PdfFileExportRequest({
    required this.mode,
    required this.destination,
    this.images = const [],
    this.groupedImages = const {},
    this.rotations = const {},
  });
}

/// Runs in a Dart worker isolate. Publish completed files by same-directory
/// rename and reserve destinations exclusively; existing files are never replaced.
Future<void> exportPdfImages(PdfFileExportRequest request) async {
  try {
    if (request.mode == PdfFileExportMode.images) {
      final directory = Directory(request.destination);
      if (!await directory.exists()) {
        throw const PdfProcessingFailure(
          PdfProcessingFailureCode.permissionDenied,
        );
      }
      for (final source in request.images) {
        await _publish(
          directory,
          path.basename(source),
          (stagingPath) =>
              _writeImage(source, stagingPath, request.rotations[source] ?? 0),
        );
      }
    } else if (request.mode == PdfFileExportMode.archive) {
      await _publish(
        Directory(path.dirname(request.destination)),
        path.basename(request.destination),
        (stagingPath) =>
            _writeArchive(stagingPath, request.images, request.rotations),
      );
    } else {
      for (final group in request.groupedImages.entries) {
        if (group.value.isEmpty) continue;
        await _publish(
          Directory(request.destination),
          '${path.basenameWithoutExtension(group.key)}.zip',
          (stagingPath) =>
              _writeArchive(stagingPath, group.value, request.rotations),
        );
      }
    }
  } on PdfProcessingFailure {
    rethrow;
  } catch (_) {
    throw const PdfProcessingFailure(PdfProcessingFailureCode.saveFailed);
  }
}

Future<void> _publish(
  Directory directory,
  String name,
  Future<void> Function(String) write,
) async {
  if (!await directory.exists()) {
    throw const PdfProcessingFailure(PdfProcessingFailureCode.permissionDenied);
  }
  final stagingDirectory = await directory.createTemp('.pixidesk-export-');
  File? reservation;
  var published = false;
  try {
    final stagedFile = File(path.join(stagingDirectory.path, 'payload'));
    await write(stagedFile.path);
    if (!await stagedFile.exists() || await stagedFile.length() == 0) {
      throw const PdfProcessingFailure(PdfProcessingFailureCode.saveFailed);
    }
    for (var suffix = 0; suffix < 10000; suffix++) {
      final candidateName = suffix == 0
          ? name
          : '${path.basenameWithoutExtension(name)}_$suffix${path.extension(name)}';
      final candidate = File(path.join(directory.path, candidateName));
      try {
        await candidate.create(exclusive: true);
        reservation = candidate;
        break;
      } on FileSystemException {
        if (await FileSystemEntity.type(candidate.path, followLinks: false) !=
            FileSystemEntityType.notFound) {
          continue;
        }
        rethrow;
      }
    }
    if (reservation == null) {
      throw const PdfProcessingFailure(
        PdfProcessingFailureCode.destinationConflict,
      );
    }
    await stagedFile.rename(reservation.path);
    published = true;
  } finally {
    if (!published && reservation != null && await reservation.exists()) {
      await reservation.delete();
    }
    if (await stagingDirectory.exists()) {
      await stagingDirectory.delete(recursive: true);
    }
  }
}

Future<void> _writeImage(
  String sourcePath,
  String destination,
  int rotation,
) async {
  final source = File(sourcePath);
  if (rotation % 4 == 0) {
    await source.copy(destination);
    return;
  }
  final decoded = image_codec.decodeImage(await source.readAsBytes());
  if (decoded == null) {
    throw const PdfProcessingFailure(PdfProcessingFailureCode.saveFailed);
  }
  final rotated = image_codec.copyRotate(decoded, angle: (rotation % 4) * 90);
  final bytes = switch (path.extension(sourcePath).toLowerCase()) {
    '.png' => image_codec.encodePng(rotated, level: 3),
    '.tiff' || '.tif' => image_codec.encodeTiff(rotated),
    '.jpg' || '.jpeg' => image_codec.encodeJpg(rotated, quality: 95),
    _ => throw const PdfProcessingFailure(PdfProcessingFailureCode.saveFailed),
  };
  await File(destination).writeAsBytes(bytes);
}

Future<void> _writeArchive(
  String destination,
  List<String> images,
  Map<String, int> rotations,
) async {
  final encoder = ZipFileEncoder()..create(destination);
  final usedNames = <String>{};
  try {
    for (final source in images) {
      final baseName = path.basename(source);
      var entryName = baseName;
      var suffix = 1;
      while (!usedNames.add(entryName.toLowerCase())) {
        entryName =
            '${path.basenameWithoutExtension(baseName)}_${suffix++}${path.extension(baseName)}';
      }
      final rotation = rotations[source] ?? 0;
      if (rotation % 4 == 0) {
        await encoder.addFile(File(source), entryName);
      } else {
        final rotated = File('$destination.rotated');
        try {
          await _writeImage(source, rotated.path, rotation);
          await encoder.addFile(rotated, entryName);
        } finally {
          if (await rotated.exists()) await rotated.delete();
        }
      }
    }
  } finally {
    encoder.close();
  }
}
