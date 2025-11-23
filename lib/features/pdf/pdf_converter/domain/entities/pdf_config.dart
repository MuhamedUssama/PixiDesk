enum PdfPageFormatOption { a4, letter, original }

enum PdfQuality { high, medium, low }

class PdfConfig {
  final PdfPageFormatOption pageFormat;
  final PdfQuality quality;

  const PdfConfig({
    this.pageFormat = PdfPageFormatOption.a4,
    this.quality = PdfQuality.high,
  });
}
