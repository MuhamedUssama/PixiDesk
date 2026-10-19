import 'dart:typed_data';
import 'dart:ui' as ui;

/// Paragraph uses the platform shaper and fallback fonts, including Arabic.
Future<Uint8List?> renderTextWatermark(String text) async {
  if (text.trim().isEmpty) return null;
  final rtl = RegExp(r'[\u0590-\u08ff]').hasMatch(text);
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textDirection: rtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      fontSize: 64,
      maxLines: 8,
    ),
  );
  builder.pushStyle(
    ui.TextStyle(
      color: const ui.Color(0xffffffff),
      shadows: [const ui.Shadow(color: ui.Color(0xff000000), blurRadius: 3)],
    ),
  );
  builder.addText(text);
  final paragraph = builder.build()
    ..layout(const ui.ParagraphConstraints(width: 1024));
  final width = paragraph.longestLine.ceil().clamp(1, 1024);
  final height = paragraph.height.ceil().clamp(1, 2048);
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawParagraph(paragraph, ui.Offset(rtl ? width - 1024.0 : 0, 0));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  paragraph.dispose();
  return data?.buffer.asUint8List();
}
