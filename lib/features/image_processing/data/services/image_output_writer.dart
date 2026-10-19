import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_recipe.dart';

class ImageOutputWriter {
  static final Set<String> _active = {};
  String _key(String path) {
    final normalized = p.normalize(p.absolute(path));
    return Platform.isWindows || Platform.isMacOS
        ? normalized.toLowerCase()
        : normalized;
  }

  Future<void> _protect(String target, List<String> sources) async {
    final exists = await File(target).exists();
    for (final source in sources) {
      if (_key(source) == _key(target) ||
          (exists &&
              await File(source).exists() &&
              await _sameFile(source, target))) {
        throw const ImageFailure(ImageFailureCode.destinationConflict);
      }
    }
  }

  Future<bool> _sameFile(String source, String target) async {
    final a = File(source), b = File(target);
    if (p.equals(
      p.normalize(p.absolute(source)),
      p.normalize(p.absolute(target)),
    )) {
      return true;
    }
    if (await b.exists()) {
      if (await FileSystemEntity.identical(source, target)) return true;
      return p.equals(
        await a.resolveSymbolicLinks(),
        await b.resolveSymbolicLinks(),
      );
    }
    final parent = await b.parent.resolveSymbolicLinks();
    return p.equals(
      await a.resolveSymbolicLinks(),
      p.join(parent, p.basename(target)),
    );
  }

  Future<String?> write({
    required String source,
    required String destination,
    List<String> protectedPaths = const [],
    required Uint8List bytes,
    required OutputConflict conflict,
    required ImageCancellation cancellation,
  }) async {
    cancellation.check();
    if (await _sameFile(source, destination)) {
      throw const ImageFailure(ImageFailureCode.destinationConflict);
    }
    await _protect(destination, protectedPaths);
    var target = File(destination);
    var index = 1;
    while (await target.exists() || _active.contains(_key(target.path))) {
      if (conflict == OutputConflict.skip) return null;
      if (conflict == OutputConflict.replace &&
          !_active.contains(_key(target.path))) {
        break;
      }
      target = File(
        p.join(
          p.dirname(destination),
          '${p.basenameWithoutExtension(destination)} (${index++})${p.extension(destination)}',
        ),
      );
    }
    final key = _key(target.path);
    _active.add(key);
    final staged = File(
      p.join(target.parent.path, '.pixidesk-${const Uuid().v4()}.tmp'),
    );
    try {
      await staged.writeAsBytes(bytes, flush: true);
      cancellation.check();
      // Recheck the final path immediately before commit, including aliases.
      if (await _sameFile(source, target.path)) {
        throw const ImageFailure(ImageFailureCode.destinationConflict);
      }
      if (await target.exists() && conflict != OutputConflict.replace) {
        throw const ImageFailure(ImageFailureCode.destinationConflict);
      }
      await _protect(target.path, protectedPaths);
      cancellation.check();
      // Same-directory rename keeps the old file intact until the final commit.
      // Platforms unable to replace atomically fail without deleting the old file.
      await staged.rename(target.path);
      return target.path;
    } on FileSystemException catch (e) {
      throw ImageFailure(
        e.osError?.errorCode == 13 || e.osError?.errorCode == 1
            ? ImageFailureCode.permissionDenied
            : ImageFailureCode.encodeFailed,
        e,
      );
    } finally {
      _active.remove(key);
      if (await staged.exists()) await staged.delete();
    }
  }
}
