import 'dart:async';

enum ImageFailureCode {
  invalidInput,
  unsupportedFormat,
  resourceLimit,
  invalidOptions,
  permissionDenied,
  destinationConflict,
  sourceChanged,
  encodeFailed,
  cancelled,
  invalidPreset,
  storageFailed,
  toolUnavailable,
  toolFailed,
}

class ImageFailure implements Exception {
  final ImageFailureCode code;
  final Object? cause;
  const ImageFailure(this.code, [this.cause]);
  @override
  String toString() => 'ImageFailure(${code.name})';
}

/// Cancellation is checked before committing output, including after worker work.
class ImageCancellation {
  bool _cancelled = false;
  final Set<void Function()> _listeners = {};
  final _signal = Completer<void>();
  Future<void> get whenCancelled => _signal.future;
  bool get isCancelled => _cancelled;
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _signal.complete();
    for (final listener in _listeners.toList()) {
      listener();
    }
    _listeners.clear();
  }

  /// Workers detach their callbacks when finished, so a long batch does not
  /// retain completed image buffers through listeners on a shared Future.
  void Function() onCancel(void Function() callback) {
    if (_cancelled) {
      callback();
      return () {};
    }
    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

  void check() {
    if (_cancelled) throw const ImageFailure(ImageFailureCode.cancelled);
  }
}
