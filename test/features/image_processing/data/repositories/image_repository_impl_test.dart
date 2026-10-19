import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/features/image_processing/data/models/image_workspace_codec.dart';
import 'package:pixi_desk/features/image_processing/data/repositories/image_workspace_repository_impl.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';

void main() {
  late Directory dir;
  late ImageWorkspaceRepositoryImpl repository;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pixidesk-workspace-test-');
    repository = ImageWorkspaceRepositoryImpl.forDirectory(dir);
  });
  tearDown(() async => dir.delete(recursive: true));
  test(
    'workspace persists Unicode presets and dated source fingerprints',
    () async {
      final entry = ImageHistoryEntry(
        id: 'job',
        sourcePath: '/صورة.png',
        outputPath: '/out.png',
        sourceBytes: 10,
        sourceModifiedMicros: 123,
        outputBytes: 5,
        createdAt: DateTime.utc(2026, 10, 19),
        recipe: const ImageRecipe(width: 32),
      );
      await repository.save(
        ImageWorkspace(
          presets: [
            const ImagePreset(
              id: 'one',
              name: 'إعداد',
              recipe: ImageRecipe(width: 32),
            ),
          ],
          history: [entry],
        ),
      );
      final loaded = await repository.load();
      expect(loaded.presets.single.name, 'إعداد');
      expect(loaded.presets.single.recipe.width, 32);
      expect(loaded.history.single.sourceModifiedMicros, 123);
      expect(loaded.history.single.createdAt, entry.createdAt);
    },
  );
  test(
    'serialized writes keep the latest snapshot and leave no temporary files',
    () async {
      await Future.wait([
        repository.save(const ImageWorkspace()),
        repository.save(
          const ImageWorkspace(
            presets: [
              ImagePreset(id: 'last', name: 'Last', recipe: ImageRecipe()),
            ],
          ),
        ),
      ]);
      expect((await repository.load()).presets.single.id, 'last');
      expect(
        await dir
            .list(recursive: true)
            .where((f) => f.path.endsWith('.tmp'))
            .isEmpty,
        isTrue,
      );
    },
  );
  test('malformed workspace reports an error without overwriting it', () async {
    await repository.save(const ImageWorkspace());
    final file = File('${dir.path}/image_workspace/workspace.json');
    await file.writeAsString('{broken');
    await expectLater(repository.load(), throwsA(isA<ImageFailure>()));
    expect(await file.readAsString(), '{broken');
  });
  test(
    'recipe JSON round trips and rejects unknown versions or invalid dimensions',
    () {
      const preset = ImagePreset(
        id: 'one',
        name: 'Arabic عربي',
        recipe: ImageRecipe(watermarkText: 'علامة', quarterTurns: 1),
      );
      expect(
        ImageWorkspaceCodec.importPreset(
          ImageWorkspaceCodec.exportPreset(preset),
        ),
        preset,
      );
      expect(
        () => ImageWorkspaceCodec.importPreset('{"version":9}'),
        throwsA(isA<ImageFailure>()),
      );
      final bad = ImageWorkspaceCodec.exportPreset(
        preset,
      ).replaceFirst('"quarterTurns":1', '"quarterTurns":99');
      expect(
        () => ImageWorkspaceCodec.importPreset(bad),
        throwsA(isA<ImageFailure>()),
      );
    },
  );
  test(
    'folder import is deterministic and does not follow directory links',
    () async {
      await File('${dir.path}/b.png').writeAsString('x');
      await File('${dir.path}/a.jpg').writeAsString('x');
      await File('${dir.path}/ignore.txt').writeAsString('x');
      await Directory('${dir.path}/sub').create();
      await File('${dir.path}/sub/c.png').writeAsString('x');
      await Link('${dir.path}/loop').create(dir.path);
      expect(
        (await repository.listImages(dir.path, recursive: false)).length,
        2,
      );
      final recursive = await repository.listImages(dir.path, recursive: true);
      expect(recursive.length, 3);
      expect(recursive.first, endsWith('a.jpg'));
    },
  );
  test('watch folders reject overlapping input and output', () async {
    await expectLater(
      repository.watchFolder(dir.path, dir.path).first,
      throwsA(isA<ImageFailure>()),
    );
  });
}
