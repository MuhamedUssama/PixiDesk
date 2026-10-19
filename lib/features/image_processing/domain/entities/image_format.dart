enum ImageFormat {
  png,
  jpg,
  jpeg,
  webp,
  bmp,
  tiff,
  ico,
  gif,
  unknown;

  ImageFormat get canonical => this == jpeg ? jpg : this;
  String get extension => canonical.name;
  bool get supportsQuality => canonical == jpg || this == webp;
  bool get supportsAnimation => [png, gif, webp, tiff].contains(this);
  bool get supportsAlpha => [png, webp, tiff, ico, gif].contains(this);
  static List<ImageFormat> get outputFormats =>
      values.where((f) => f != jpeg && f != unknown).toList(growable: false);

  static ImageFormat fromPath(String path) {
    final ext = path.split(RegExp(r'[/\\]')).last.split('.').last.toLowerCase();
    if (ext == 'jpeg') return jpg;
    if (ext == 'tif') return tiff;
    return values.firstWhere((f) => f.name == ext, orElse: () => unknown);
  }
}
