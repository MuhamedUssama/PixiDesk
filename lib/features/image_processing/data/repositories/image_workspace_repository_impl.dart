import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/image_failure.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/repositories/image_workspace_repository.dart';
import '../models/image_workspace_codec.dart';

@LazySingleton(as: ImageWorkspaceRepository)
class ImageWorkspaceRepositoryImpl implements ImageWorkspaceRepository {
  final Future<Directory> Function() _support;
  ImageWorkspaceRepositoryImpl() : _support = getApplicationSupportDirectory;

  /// Allows real filesystem tests without platform channels.
  ImageWorkspaceRepositoryImpl.forDirectory(Directory directory)
    : _support = (() async => directory);
  Future<void> _pending = Future.value();
  Future<File> _file() async {
    final dir = Directory(p.join((await _support()).path, 'image_workspace'));
    await dir.create(recursive: true);
    return File(p.join(dir.path, 'workspace.json'));
  }

  @override
  Future<ImageWorkspace> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const ImageWorkspace();
      if (await file.length() > 2 * 1024 * 1024) {
        throw const ImageFailure(ImageFailureCode.storageFailed);
      }
      return ImageWorkspaceCodec.decode(await file.readAsString());
    } on ImageFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure(ImageFailureCode.storageFailed, e);
    }
  }

  @override
  Future<void> save(ImageWorkspace workspace) {
    final result = _pending.then((_) async {
      final file = await _file();
      final temp = File('${file.path}.tmp');
      try {
        await temp.writeAsString(
          ImageWorkspaceCodec.encode(workspace),
          flush: true,
        );
        await temp.rename(file.path);
      } catch (e) {
        throw ImageFailure(ImageFailureCode.storageFailed, e);
      } finally {
        if (await temp.exists()) await temp.delete();
      }
    });
    _pending = result.catchError((Object _) {});
    return result;
  }

  @override
  Future<String> encodePreset(ImagePreset preset) async =>
      ImageWorkspaceCodec.exportPreset(preset);
  @override
  Future<ImagePreset> decodePreset(String json) async =>
      ImageWorkspaceCodec.importPreset(json);
  @override
  Future<List<String>> listImages(
    String directory, {
    required bool recursive,
  }) async {
    final paths = <String>[];
    try {
      await for (final entity in Directory(
        directory,
      ).list(recursive: recursive, followLinks: false)) {
        if (entity is File &&
            ImageFormat.fromPath(entity.path) != ImageFormat.unknown) {
          paths.add(entity.path);
          if (paths.length > 1000) {
            throw const ImageFailure(ImageFailureCode.resourceLimit);
          }
        }
      }
      paths.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return paths;
    } on ImageFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure(ImageFailureCode.permissionDenied, e);
    }
  }

  @override
  Stream<String> watchFolder(String input, String output) {
    late StreamController<String> controller;
    Timer? timer;
    var scanning = false;
    var stopped = false;
    final seen = <String, String>{};
    final candidates = <String, (String, int)>{};
    Future<void> scan({bool baseline = false}) async {
      if (scanning || stopped || controller.isClosed) return;
      scanning = true;
      try {
        final a = await Directory(input).resolveSymbolicLinks();
        final b = await Directory(output).resolveSymbolicLinks();
        if (p.equals(a, b) || p.isWithin(a, b) || p.isWithin(b, a)) {
          throw const ImageFailure(ImageFailureCode.invalidOptions);
        }
        final paths = await listImages(input, recursive: false);
        for (final path in paths) {
          final stat = await File(path).stat();
          final signature =
              '${stat.size}:${stat.modified.microsecondsSinceEpoch}';
          if (baseline) {
            seen[path] = signature;
            continue;
          }
          if (seen[path] == signature || stat.size == 0) continue;
          final previous = candidates[path];
          final count = previous?.$1 == signature ? previous!.$2 + 1 : 0;
          candidates[path] = (signature, count);
          if (count >= 2) {
            seen[path] = signature;
            candidates.remove(path);
            if (!stopped && !controller.isClosed) controller.add(path);
          }
        }
        candidates.removeWhere((path, _) => !paths.contains(path));
      } catch (e, stack) {
        if (!stopped && !controller.isClosed) controller.addError(e, stack);
      } finally {
        scanning = false;
      }
    }

    controller = StreamController<String>(
      onListen: () async {
        await scan(baseline: true);
        if (!stopped && !controller.isClosed) {
          timer = Timer.periodic(const Duration(seconds: 1), (_) => scan());
        }
      },
      onCancel: () {
        stopped = true;
        timer?.cancel();
      },
    );
    return controller.stream;
  }
}
