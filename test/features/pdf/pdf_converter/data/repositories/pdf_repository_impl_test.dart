import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixi_desk/features/pdf/pdf_converter/data/repositories/pdf_repository_impl.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/domain/entities/pdf_config.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/domain/entities/pdf_image_item.dart';

void main() {
  test(
    'image workspace PNG and WebP exports can become ordered PDF pages',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pixidesk-pdf-test-',
      );
      try {
        final image = img.Image(width: 48, height: 32, numChannels: 4);
        img.fill(image, color: img.ColorRgba8(120, 80, 200, 220));
        final png = await File(
          '${directory.path}/first.png',
        ).writeAsBytes(img.encodePng(image));
        final webp = await File(
          '${directory.path}/second.webp',
        ).writeAsBytes(img.encodeWebP(image));
        final output = await PdfRepositoryImpl().generatePdf(
          images: [
            PdfImageItem(id: 'first', file: png),
            PdfImageItem(id: 'second', file: webp),
          ],
          config: const PdfConfig(pageFormat: PdfPageFormatOption.original),
          outputPath: '${directory.path}/images.pdf',
        );
        final bytes = await output.readAsBytes();
        expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
        expect(RegExp(r'/Count\s+2\b').hasMatch(latin1.decode(bytes)), isTrue);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
