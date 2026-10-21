import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_bindings.dart';
import 'package:pixi_desk/features/pdf/shared/data/pdfium/pdfium_document.dart';
import 'package:pixi_desk/features/pdf/shared/domain/entities/pdf_processing_failure.dart';

/// Serial JSON-lines protocol. One OS process owns one PDFium library instance.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    exitCode = 64;
    return;
  }
  PdfiumDocument? document;
  String? currentSource;
  String? currentPassword;
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
        final password = request['password'] as String?;
        if (sourcePath != currentSource || password != currentPassword) {
          document?.close();
          document = null;
          currentSource = null;
          currentPassword = null;
          document = PdfiumDocument.open(
            bindings,
            sourcePath,
            password: password,
          );
          currentSource = sourcePath;
          currentPassword = password;
        }
        final result = switch (request['type']) {
          'inspect' => <String, Object>{'pages': document!.inspect()},
          'render' => document!.render(
            request['pageIndex'] as int,
            request['dpi'] as int,
            request['format'] as String,
            request['outputPath'] as String,
            maxDimension: request['maxDimension'] as int?,
            includePreviewAssets: request['includePreviewAssets'] != false,
          ),
          _ => throw const PdfProcessingFailure(
            PdfProcessingFailureCode.invalidSettings,
          ),
        };
        stdout.writeln(jsonEncode({'id': request['id'], 'result': result}));
      } catch (error) {
        final code = error is PdfProcessingFailure
            ? error.code
            : (error is FileSystemException
                  ? PdfProcessingFailureCode.permissionDenied
                  : PdfProcessingFailureCode.workerFailed);
        stdout.writeln(jsonEncode({'id': request?['id'], 'error': code.name}));
      }
    }
  } finally {
    document?.close();
    bindings.FPDF_DestroyLibrary();
  }
}
