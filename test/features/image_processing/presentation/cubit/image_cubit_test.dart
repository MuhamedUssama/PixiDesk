import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/presentation/cubit/image_cubit.dart';
import 'package:pixi_desk/features/image_processing/presentation/cubit/image_state.dart';
import '../../support/fakes.dart';

void main() {
  late FakeImageRepository repo;
  late FakeDesktop desktop;
  late FakeWorkspace workspace;
  late ImageCubit cubit;
  setUp(() async {
    repo = FakeImageRepository();
    desktop = FakeDesktop();
    workspace = FakeWorkspace();
    cubit = makeCubit(repo, desktop, workspace);
    await cubit.initialize();
  });
  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
    await workspace.watch.close();
  });
  test(
    'batch import rejects one invalid item without losing valid inputs',
    () async {
      repo.failPaths.add('/bad.png');
      await cubit.addImages(['/a.png', '/bad.png', '/b.jpg']);
      expect(cubit.state.jobs.length, 2);
      expect(cubit.state.failure, ImageFailureCode.invalidInput);
      expect(cubit.state.operation, ImageOperation.idle);
    },
  );
  test(
    'save dialog freezes source and settings; repeated calls cannot race',
    () async {
      await cubit.addImages(['/a.final.png', '/b.png']);
      cubit.selectImage(0);
      cubit.updateRecipe(const ImageRecipe(format: ImageFormat.jpg));
      desktop.saveGate = Completer<String?>();
      final pending = cubit.exportImage('title');
      cubit.selectImage(1);
      cubit.updateRecipe(const ImageRecipe(format: ImageFormat.bmp));
      await cubit.exportImage('duplicate');
      expect(cubit.state.operation, ImageOperation.choosingDestination);
      expect(desktop.suggestedName, 'a.final_edited.jpg');
      desktop.saveGate!.complete('/output/a.final.jpg');
      await pending;
      expect(repo.requests, hasLength(1));
      expect(repo.requests.single.source.path, '/a.final.png');
      expect(repo.requests.single.recipe.format, ImageFormat.jpg);
      expect(cubit.state.jobs.first.status, ImageJobStatus.completed);
      expect(cubit.state.history.single.outputPath, '/output/a.final.jpg');
    },
  );
  test('cancelled save dialog never invokes processing', () async {
    await cubit.addImages(['/a.png']);
    desktop.saveGate = Completer<String?>();
    final pending = cubit.exportImage('title');
    cubit.cancel();
    desktop.saveGate!.complete('/out.png');
    await pending;
    expect(repo.requests, isEmpty);
    expect(cubit.state.operation, ImageOperation.idle);
  });
  test(
    'encoding cancellation marks the active job cancelled and allows retry',
    () async {
      await cubit.addImages(['/a.png']);
      repo.gate = Completer<void>();
      final pending = cubit.exportBatch('title');
      await Future<void>.delayed(Duration.zero);
      cubit.cancel();
      await pending;
      expect(cubit.state.jobs.single.status, ImageJobStatus.cancelled);
      repo.gate = null;
      await cubit.exportBatch('title', failedOnly: true);
      expect(cubit.state.jobs.single.status, ImageJobStatus.completed);
    },
  );
  test(
    'batch failures are isolated and retry does not rerun completed jobs',
    () async {
      await cubit.addImages(['/a.png', '/b.png']);
      repo.failPaths.add('/a.png');
      await cubit.exportBatch('title');
      expect(cubit.state.jobs[0].status, ImageJobStatus.failed);
      expect(cubit.state.jobs[1].status, ImageJobStatus.completed);
      repo.failPaths.clear();
      await cubit.exportBatch('title', failedOnly: true);
      expect(
        repo.requests.where((r) => r.source.path == '/b.png'),
        hasLength(1),
      );
      expect(
        cubit.state.jobs.every((j) => j.status == ImageJobStatus.completed),
        isTrue,
      );
    },
  );
  test('pause stops scheduling subsequent items until resumed', () async {
    await cubit.addImages(['/a.png', '/b.png']);
    repo.gate = Completer<void>();
    final pending = cubit.exportBatch('title');
    await Future<void>.delayed(Duration.zero);
    cubit.togglePause();
    repo.gate!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(repo.requests, hasLength(1));
    expect(cubit.state.paused, isTrue);
    cubit.togglePause();
    await pending;
    expect(repo.requests, hasLength(2));
  });
  test('close during work prevents later state emissions', () async {
    await cubit.addImages(['/a.png']);
    repo.gate = Completer<void>();
    final pending = cubit.preview();
    await cubit.close();
    await pending;
    expect(cubit.isClosed, isTrue);
    expect(desktop.disposed, isTrue);
  });
  test('undo redo use immutable recipes and a new edit clears redo', () {
    cubit.updateRecipe(const ImageRecipe(width: 60));
    cubit.updateRecipe(const ImageRecipe(width: 30));
    cubit.undo();
    expect(cubit.state.recipe.width, 60);
    cubit.redo();
    expect(cubit.state.recipe.width, 30);
    cubit.undo();
    cubit.updateRecipe(const ImageRecipe(width: 20));
    expect(cubit.state.canRedo, isFalse);
  });
  test(
    'unreadable saved workspace is never overwritten by preset edits',
    () async {
      await cubit.close();
      workspace.failLoad = true;
      cubit = makeCubit(repo, desktop, workspace);
      await cubit.initialize();
      await cubit.savePreset('test');
      expect(workspace.saves, 0);
      expect(cubit.state.failure, ImageFailureCode.storageFailed);
    },
  );
  test('changed sources cannot be silently restored from history', () async {
    await cubit.addImages(['/a.png']);
    await cubit.exportImage('title');
    final entry = cubit.state.history.single;
    cubit.clearQueue();
    repo.assets['/a.png'] = asset('/a.png');
    await cubit.restoreHistory(entry);
    expect(cubit.state.selectedImage?.path, '/a.png');
  });
  test(
    'watch folders snapshot recipe and process queued events once idle',
    () async {
      cubit.updateRecipe(const ImageRecipe(format: ImageFormat.jpg));
      await cubit.startWatching('input', 'output');
      cubit.updateRecipe(const ImageRecipe(format: ImageFormat.bmp));
      workspace.watch.add('/new.png');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(repo.requests.single.recipe.format, ImageFormat.jpg);
      await cubit.stopWatching();
      expect(cubit.state.watching, isFalse);
    },
  );
  test(
    'cancelled batches journal unstarted items and recover without auto-export',
    () async {
      await cubit.addImages(['/a.png', '/b.png']);
      repo.gate = Completer<void>();
      final pending = cubit.exportBatch('title');
      await Future<void>.delayed(Duration.zero);
      expect(workspace.workspace.recovery.length, 2);
      cubit.cancel();
      await pending;
      expect(
        cubit.state.jobs.every((j) => j.status == ImageJobStatus.cancelled),
        isTrue,
      );
      expect(workspace.workspace.recovery.length, 2);
      await cubit.close();
      repo.requests.clear();
      repo.gate = null;
      cubit = makeCubit(repo, desktop, workspace);
      await cubit.initialize();
      expect(cubit.state.recovery.length, 2);
      expect(repo.requests, isEmpty);
      await cubit.restoreHistory(cubit.state.recovery.first);
      expect(cubit.state.jobs.single.source.path, '/a.png');
      expect(cubit.state.recovery.length, 1);
    },
  );
  test(
    'preset duplication keeps its recipe and rename keeps identity',
    () async {
      await cubit.savePreset('Original', recipe: const ImageRecipe(width: 30));
      final first = cubit.state.presets.single;
      cubit.updateRecipe(const ImageRecipe(width: 60));
      await cubit.savePreset('Copy', recipe: first.recipe);
      await cubit.renamePreset(first.id, 'جديد');
      expect(cubit.state.presets.first.id, first.id);
      expect(cubit.state.presets.first.name, 'جديد');
      expect(cubit.state.presets.last.recipe.width, 30);
    },
  );
}
