import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/pdf_export_dialogs.dart';

@Injectable(as: PdfExportDialogs)
class PdfExportDialogsImpl implements PdfExportDialogs {
  @override
  Future<String?> chooseFolder() => FilePicker.platform.getDirectoryPath();
  @override
  Future<String?> chooseZipPath(String title) => FilePicker.platform.saveFile(
    dialogTitle: title,
    fileName: 'converted_images.zip',
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );
}
