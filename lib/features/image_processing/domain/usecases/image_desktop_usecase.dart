import 'package:injectable/injectable.dart';
import '../entities/image_failure.dart';
import '../services/image_desktop_gateway.dart';

@injectable
class ImageDesktopUseCase {
  final ImageDesktopGateway _gateway;
  ImageDesktopUseCase(this._gateway);
  Future<List<String>> pickImages(String title) => _gateway.pickImages(title);
  Future<String?> pickFolder(String title) => _gateway.pickFolder(title);
  Future<String?> savePath(
    String title,
    String name,
    List<String> extensions,
  ) => _gateway.savePath(title, name, extensions);
  Future<List<String>> pasteImages() => _gateway.pasteImages();
  Future<void> openFile(String path, {bool reveal = false}) =>
      _gateway.openFile(path, reveal: reveal);
  Future<String?> readPreset(String title) => _gateway.readPreset(title);
  Future<void> writeText(String title, String name, String text) =>
      _gateway.writeText(title, name, text);
  Future<String> recognizeText(
    String path,
    String language,
    ImageCancellation token,
  ) => _gateway.recognizeText(path, language, token);
  Future<String> removeBackground(String path, ImageCancellation token) =>
      _gateway.removeBackground(path, token);
  Future<void> dispose() => _gateway.disposeTemporaryFiles();
}
