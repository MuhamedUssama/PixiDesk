import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/pdf_merge_failure.dart';
import '../../domain/services/pdf_merge_desktop_gateway.dart';

@Injectable(as: PdfMergeDesktopGateway)
class PdfMergeDesktopGatewayImpl implements PdfMergeDesktopGateway {
  @override
  Future<List<String>> selectDocuments() async =>
      (await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            allowMultiple: true,
          ))?.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList() ??
      [];
  @override
  Future<String?> selectDestination(String title) =>
      FilePicker.platform.saveFile(
        dialogTitle: title,
        fileName: 'merged.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
  @override
  Future<void> openDocument(String documentPath) =>
      _launch(documentPath, false);
  @override
  Future<void> revealDocument(String documentPath) =>
      _launch(documentPath, true);

  Future<void> _launch(String documentPath, bool reveal) async {
    try {
      if (!await File(documentPath).exists()) {
        throw const PdfMergeFailure(PdfMergeFailureCode.launchFailed);
      }
      final executable = Platform.isMacOS
          ? '/usr/bin/open'
          : Platform.isWindows
          ? 'explorer.exe'
          : 'xdg-open';
      final arguments = Platform.isMacOS
          ? [if (reveal) '-R', documentPath]
          : Platform.isWindows
          ? [if (reveal) '/select,', documentPath]
          : [reveal ? path.dirname(documentPath) : documentPath];
      final result = await Process.run(
        executable,
        arguments,
        runInShell: false,
      ).timeout(const Duration(seconds: 15));
      if (!Platform.isWindows && result.exitCode != 0) {
        throw const PdfMergeFailure(PdfMergeFailureCode.launchFailed);
      }
    } catch (_) {
      throw const PdfMergeFailure(PdfMergeFailureCode.launchFailed);
    }
  }
}
