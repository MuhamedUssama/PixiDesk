import '../entities/image_job.dart';

abstract class ImageWorkspaceRepository {
  Future<ImageWorkspace> load();
  Future<void> save(ImageWorkspace workspace);
  Future<String> encodePreset(ImagePreset preset);
  Future<ImagePreset> decodePreset(String json);
  Future<List<String>> listImages(String directory, {required bool recursive});

  /// Emits only stable files; runs while subscribed and never follows symlinks.
  Stream<String> watchFolder(String input, String output);
}
