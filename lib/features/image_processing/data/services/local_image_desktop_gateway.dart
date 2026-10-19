import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/image_failure.dart';
import '../../domain/services/image_desktop_gateway.dart';

@Injectable(as: ImageDesktopGateway)
class LocalImageDesktopGateway implements ImageDesktopGateway {
  final Set<Directory> _temporary = {};
  static const _channel = MethodChannel('pixidesk/images');
  @override
  Future<List<String>> pickImages(String title) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: title,
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
        'webp',
        'bmp',
        'tif',
        'tiff',
        'ico',
        'gif',
      ],
    );
    return result?.paths.whereType<String>().toList() ?? [];
  }

  @override
  Future<String?> pickFolder(String title) =>
      FilePicker.platform.getDirectoryPath(dialogTitle: title);
  @override
  Future<String?> savePath(
    String title,
    String name,
    List<String> extensions,
  ) => FilePicker.platform.saveFile(
    dialogTitle: title,
    fileName: name,
    type: FileType.custom,
    allowedExtensions: extensions,
  );
  @override
  Future<List<String>> pasteImages() async {
    if (Platform.isMacOS) {
      final bytes = await _channel.invokeMethod<Uint8List>('pasteImage');
      if (bytes != null) {
        final dir = await Directory.systemTemp.createTemp(
          'pixidesk-clipboard-',
        );
        _temporary.add(dir);
        final file = await File(
          p.join(dir.path, 'clipboard.png'),
        ).writeAsBytes(bytes);
        return [file.path];
      }
    }
    if (Platform.isWindows || Platform.isLinux) {
      final dir = await Directory.systemTemp.createTemp('pixidesk-clipboard-');
      _temporary.add(dir);
      final path = p.join(dir.path, 'clipboard.png');
      if (Platform.isWindows) {
        const script =
            r'Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $image = [System.Windows.Forms.Clipboard]::GetImage(); if ($null -ne $image) { $image.Save($env:PIXIDESK_CLIPBOARD_FILE, [System.Drawing.Imaging.ImageFormat]::Png); $image.Dispose() }';
        try {
          await Process.run(
            'powershell.exe',
            ['-NoProfile', '-NonInteractive', '-STA', '-Command', script],
            environment: {'PIXIDESK_CLIPBOARD_FILE': path},
            runInShell: false,
          );
          if (await File(path).exists()) return [path];
        } on ProcessException {
          /* Fall back to file paths. */
        }
      } else {
        for (final command in [
          ['wl-paste', '--no-newline', '--type', 'image/png'],
          ['xclip', '-selection', 'clipboard', '-t', 'image/png', '-o'],
        ]) {
          try {
            final result = await Process.run(
              command.first,
              command.skip(1).toList(),
              stdoutEncoding: null,
              runInShell: false,
            );
            if (result.exitCode == 0 &&
                result.stdout is List<int> &&
                (result.stdout as List<int>).isNotEmpty) {
              final bytes = result.stdout as List<int>;
              if (bytes.length > 64 * 1024 * 1024) {
                throw const ImageFailure(ImageFailureCode.resourceLimit);
              }
              await File(path).writeAsBytes(bytes);
              return [path];
            }
          } on ProcessException {
            /* Try the other desktop clipboard provider. */
          }
        }
      }
    }
    // File URLs/paths copied in Explorer, Finder and Linux file managers.
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    final paths = <String>[];
    for (final line in const LineSplitter().convert(text)) {
      final candidate = line.trim();
      if (candidate.isEmpty || candidate.startsWith('#')) continue;
      final uri = Uri.tryParse(candidate);
      final path = uri?.scheme == 'file' ? uri!.toFilePath() : candidate;
      if (await File(path).exists()) paths.add(path);
    }
    return paths;
  }

  @override
  Future<void> openFile(String path, {bool reveal = false}) async {
    if (!await File(path).exists()) {
      throw const ImageFailure(ImageFailureCode.invalidInput);
    }
    final executable = Platform.isMacOS
        ? '/usr/bin/open'
        : Platform.isWindows
        ? 'explorer.exe'
        : 'xdg-open';
    final args = Platform.isMacOS
        ? [if (reveal) '-R', path]
        : Platform.isWindows && reveal
        ? ['/select,', path]
        : [reveal ? p.dirname(path) : path];
    try {
      final result = await Process.run(executable, args, runInShell: false);
      if (result.exitCode != 0) {
        throw const ImageFailure(ImageFailureCode.permissionDenied);
      }
    } on ProcessException catch (e) {
      throw ImageFailure(ImageFailureCode.toolUnavailable, e);
    }
  }

  @override
  Future<String?> readPreset(String title) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: title,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    final file = File(path);
    if (await file.length() > 65536) {
      throw const ImageFailure(ImageFailureCode.invalidPreset);
    }
    return file.readAsString();
  }

  @override
  Future<void> writeText(String title, String name, String text) async {
    final ext = p.extension(name).replaceFirst('.', '');
    final path = await savePath(title, name, [ext]);
    if (path == null) return;
    final target = path.toLowerCase().endsWith('.$ext') ? path : '$path.$ext';
    // Never replace a different path than the one confirmed by the native dialog.
    if (target != path && await File(target).exists()) {
      throw const ImageFailure(ImageFailureCode.destinationConflict);
    }
    await File(target).writeAsString(text, flush: true);
  }

  Future<String> _run(
    String command,
    List<String> args,
    ImageCancellation token,
  ) async {
    token.check();
    Process process;
    try {
      process = await Process.start(command, args, runInShell: false);
    } on ProcessException catch (e) {
      throw ImageFailure(ImageFailureCode.toolUnavailable, e);
    }
    // Consume both pipes immediately to prevent a full stderr pipe deadlocking a job.
    final stdout = process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .join();
    final stderr = process.stderr.drain<void>();
    final timeout = Completer<int>();
    final timer = Timer(const Duration(minutes: 2), () {
      process.kill();
      timeout.completeError(const ImageFailure(ImageFailureCode.toolFailed));
    });
    var running = true;
    try {
      final code = await Future.any([
        process.exitCode,
        token.whenCancelled.then<int>((_) {
          if (running) process.kill();
          throw const ImageFailure(ImageFailureCode.cancelled);
        }),
        timeout.future,
      ]);
      await stderr;
      final output = await stdout;
      token.check();
      if (code != 0) throw const ImageFailure(ImageFailureCode.toolFailed);
      return output;
    } finally {
      running = false;
      timer.cancel();
      process.kill();
    }
  }

  @override
  Future<String> recognizeText(
    String path,
    String language,
    ImageCancellation token,
  ) {
    if (!['eng', 'ara', 'ara+eng'].contains(language)) {
      throw const ImageFailure(ImageFailureCode.invalidOptions);
    }
    return _run('tesseract', [path, 'stdout', '-l', language], token);
  }

  @override
  Future<String> removeBackground(String path, ImageCancellation token) async {
    final dir = await Directory.systemTemp.createTemp('pixidesk-cutout-');
    _temporary.add(dir);
    final output = p.join(dir.path, 'cutout.png');
    // Uses an already installed local model. Never implicitly download models.
    final modelHome = Platform.environment['U2NET_HOME'];
    if (modelHome == null ||
        !await File(p.join(modelHome, 'u2net.onnx')).exists()) {
      throw const ImageFailure(ImageFailureCode.toolUnavailable);
    }
    await _run('rembg', ['i', '-m', 'u2net', path, output], token);
    if (!await File(output).exists()) {
      throw const ImageFailure(ImageFailureCode.toolFailed);
    }
    return output;
  }

  @override
  Future<void> disposeTemporaryFiles() async {
    for (final dir in _temporary) {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
    _temporary.clear();
  }
}
