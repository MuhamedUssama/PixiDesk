enum CompressionLevel {
  /// Screen-view-only quality, 72 dpi images
  screen,

  /// Low quality, 150 dpi images
  ebook,

  /// High quality, 300 dpi images
  printer,

  /// High quality, color preserving, 300 dpi images
  prepress,

  /// Default quality
  defaultCompression;

  String get ghostscriptValue {
    switch (this) {
      case CompressionLevel.screen:
        return '/screen';
      case CompressionLevel.ebook:
        return '/ebook';
      case CompressionLevel.printer:
        return '/printer';
      case CompressionLevel.prepress:
        return '/prepress';
      case CompressionLevel.defaultCompression:
        return '/default';
    }
  }
}
