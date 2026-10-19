import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/pdfium/pdfium_bindings.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/pdfium/pdfium_document.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_conversion_failure.dart';

/// Serial JSON-lines protocol. One OS process owns one PDFium library instance.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    exitCode = 64;
    return;
  }
  PdfiumDocument? document;
  String? currentSource;
  final bindings = PdfiumBindings(DynamicLibrary.open(arguments.single));
  bindings.FPDF_InitLibrary();
  stdout.writeln(
    jsonEncode({'type': 'ready', 'protocol': 1, 'revision': 'chromium/8100'}),
  );
  try {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.length > 1024 * 1024) {
        exitCode = 65;
        break;
      }
      Map<String, dynamic>? request;
      try {
        request = jsonDecode(line) as Map<String, dynamic>;
        final sourcePath = request['sourcePath'] as String;
        if (sourcePath != currentSource) {
          document?.close();
          document = null;
          currentSource = null;
          document = PdfiumDocument.open(bindings, sourcePath);
          currentSource = sourcePath;
        }
        final result = switch (request['type']) {
          'inspect' => <String, Object>{'pages': document!.inspect()},
          'render' => document!.render(
            request['pageIndex'] as int,
            request['dpi'] as int,
            request['format'] as String,
            request['outputPath'] as String,
          ),
          _ => throw const PdfConversionFailure(
            PdfConversionFailureCode.invalidSettings,
          ),
        };
        stdout.writeln(jsonEncode({'id': request['id'], 'result': result}));
      } catch (error) {
        final code = error is PdfConversionFailure
            ? error.code
            : (error is FileSystemException
                  ? PdfConversionFailureCode.permissionDenied
                  : PdfConversionFailureCode.workerFailed);
        stdout.writeln(jsonEncode({'id': request?['id'], 'error': code.name}));
      }
    }
  } finally {
    document?.close();
    bindings.FPDF_DestroyLibrary();
  }
}
