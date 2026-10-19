import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// OS file-open events and command-line arguments are translated into paths.
class DesktopImageIntake {
  static const _channel = MethodChannel('pixidesk/image_intake');
  final _events = StreamController<List<String>>.broadcast();
  Stream<List<String>> get events => _events.stream;
  Future<void> initialize(List<String> arguments) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFiles' && call.arguments is List) {
        await _accept((call.arguments as List).whereType<String>().toList());
      }
    });
    await _accept(arguments);
    if (Platform.isMacOS) {
      try {
        await _accept(
          await _channel.invokeListMethod<String>('takeOpenFiles') ?? [],
        );
      } on MissingPluginException {
        /* Unit tests and unsupported hosts. */
      }
    }
  }

  Future<void> _accept(List<String> paths) async {
    final files = <String>[];
    for (final path in paths) {
      if (!path.startsWith('-') && await File(path).exists()) files.add(path);
    }
    if (files.isNotEmpty && !_events.isClosed) _events.add(files);
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _events.close();
  }
}
