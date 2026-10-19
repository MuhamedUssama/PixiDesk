import '../entities/image_failure.dart';

abstract interface class ImageDesktopGateway {
  Future<List<String>> pickImages(String title);
  Future<String?> pickFolder(String title);
  Future<String?> savePath(String title, String name, List<String> extensions);
  Future<List<String>> pasteImages();
  Future<void> openFile(String path, {bool reveal = false});
  Future<String?> readPreset(String title);
  Future<void> writeText(String title, String name, String text);
  Future<String> recognizeText(
    String path,
    String language,
    ImageCancellation cancellation,
  );
  Future<String> removeBackground(String path, ImageCancellation cancellation);
  Future<void> disposeTemporaryFiles();
}
