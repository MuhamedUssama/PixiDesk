import 'dart:async';
import 'dart:typed_data';
import 'package:pixi_desk/features/image_processing/domain/entities/image_entity.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/domain/repositories/image_repository.dart';
import 'package:pixi_desk/features/image_processing/domain/repositories/image_workspace_repository.dart';
import 'package:pixi_desk/features/image_processing/domain/services/image_desktop_gateway.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/process_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/convert_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/compress_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/preview_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/image_workspace_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/image_desktop_usecase.dart';
import 'package:pixi_desk/features/image_processing/presentation/cubit/image_cubit.dart';

ImageEntity asset(
  String path, {
  ImageFormat format = ImageFormat.png,
  Uint8List? thumbnail,
}) => ImageEntity(
  path: path,
  name: path.split('/').last,
  sizeInBytes: 100,
  format: format,
  width: 120,
  height: 60,
  thumbnail: thumbnail ?? Uint8List(0),
  modifiedMicros: 123,
);

class FakeImageRepository implements ImageRepository {
  final Map<String, ImageEntity> assets = {};
  final List<ImageRequest> requests = [];
  final Set<String> failPaths = {};
  Completer<void>? gate;
  @override
  Future<ImageEntity> inspect(String path, ImageCancellation token) async {
    token.check();
    if (failPaths.contains(path)) {
      throw const ImageFailure(ImageFailureCode.invalidInput);
    }
    return assets[path] ?? asset(path);
  }

  @override
  Future<ImageResult> process(
    ImageRequest request,
    ImageCancellation token,
  ) async {
    requests.add(request);
    if (gate != null) await Future.any([gate!.future, token.whenCancelled]);
    token.check();
    if (failPaths.contains(request.source.path)) {
      throw const ImageFailure(ImageFailureCode.encodeFailed);
    }
    return ImageResult(
      path: request.destinationPath,
      originalBytes: request.source.sizeInBytes,
      outputBytes: 50,
      width: 60,
      height: 30,
      elapsed: Duration.zero,
      thumbnail: request.source.thumbnail,
    );
  }

  @override
  Future<Uint8List> preview(
    ImageEntity source,
    ImageRecipe recipe,
    ImageCancellation token,
  ) async {
    if (gate != null) await Future.any([gate!.future, token.whenCancelled]);
    token.check();
    return source.thumbnail;
  }
}

class FakeDesktop implements ImageDesktopGateway {
  Completer<String?>? saveGate;
  String? suggestedName;
  List<String> picked = [];
  String folder = '/output';
  bool disposed = false;
  @override
  Future<List<String>> pickImages(String title) async => picked;
  @override
  Future<String?> pickFolder(String title) async => folder;
  @override
  Future<String?> savePath(String title, String name, List<String> extensions) {
    suggestedName = name;
    return saveGate?.future ?? Future.value('/output/$name');
  }

  @override
  Future<List<String>> pasteImages() async => picked;
  @override
  Future<void> openFile(String path, {bool reveal = false}) async {}
  @override
  Future<String?> readPreset(String title) async => null;
  @override
  Future<void> writeText(String title, String name, String text) async {}
  @override
  Future<String> recognizeText(
    String path,
    String language,
    ImageCancellation cancellation,
  ) async => 'نص';
  @override
  Future<String> removeBackground(
    String path,
    ImageCancellation cancellation,
  ) async => '/cutout.png';
  @override
  Future<void> disposeTemporaryFiles() async {
    disposed = true;
  }
}

class FakeWorkspace implements ImageWorkspaceRepository {
  ImageWorkspace workspace = const ImageWorkspace();
  int saves = 0;
  bool failLoad = false;
  final watch = StreamController<String>.broadcast();
  @override
  Future<ImageWorkspace> load() async {
    if (failLoad) throw const ImageFailure(ImageFailureCode.storageFailed);
    return workspace;
  }

  @override
  Future<void> save(ImageWorkspace value) async {
    saves++;
    workspace = value;
  }

  @override
  Future<String> encodePreset(ImagePreset preset) async => '';
  @override
  Future<ImagePreset> decodePreset(String json) async =>
      throw UnimplementedError();
  @override
  Future<List<String>> listImages(
    String directory, {
    required bool recursive,
  }) async => [];
  @override
  Stream<String> watchFolder(String input, String output) => watch.stream;
}

ImageCubit makeCubit(
  FakeImageRepository repository,
  FakeDesktop desktop,
  FakeWorkspace workspace,
) {
  final process = ProcessImageUseCase(repository);
  return ImageCubit(
    process,
    ConvertImageUseCase(process),
    CompressImageUseCase(process),
    PreviewImageUseCase(repository),
    ImageDesktopUseCase(desktop),
    ImageWorkspaceUseCase(workspace),
  );
}
