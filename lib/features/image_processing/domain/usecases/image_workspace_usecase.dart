import 'package:injectable/injectable.dart';
import '../entities/image_job.dart';
import '../repositories/image_workspace_repository.dart';

@lazySingleton
class ImageWorkspaceUseCase {
  final ImageWorkspaceRepository _repository;
  ImageWorkspaceUseCase(this._repository);
  Future<ImageWorkspace> load() => _repository.load();
  Future<void> save(ImageWorkspace workspace) => _repository.save(workspace);
  Future<String> encodePreset(ImagePreset preset) =>
      _repository.encodePreset(preset);
  Future<ImagePreset> decodePreset(String text) =>
      _repository.decodePreset(text);
  Future<List<String>> listImages(
    String directory, {
    required bool recursive,
  }) => _repository.listImages(directory, recursive: recursive);
  Stream<String> watchFolder(String input, String output) =>
      _repository.watchFolder(input, output);
}
