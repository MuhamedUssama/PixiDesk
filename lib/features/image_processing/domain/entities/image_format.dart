enum ImageFormat {
  png,
  jpg,
  jpeg,
  webp,
  bmp,
  tiff,
  ico,
  gif;

  String get extension => name;

  static ImageFormat fromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ImageFormat.values.firstWhere(
      (e) => e.name == ext || (e == ImageFormat.jpg && ext == 'jpeg'),
      orElse: () => ImageFormat.png,
    );
  }
}
