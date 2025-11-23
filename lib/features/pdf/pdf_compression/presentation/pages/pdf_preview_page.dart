import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;

  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.previewPdf),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final outputPath = await FilePicker.platform.saveFile(
                dialogTitle: l10n.saveAs,
                fileName: pdfFile.path.split(Platform.pathSeparator).last,
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (outputPath != null) {
                await pdfFile.copy(outputPath);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.imageSaved),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: Icon(Icons.save, color: isDark ? Colors.white : Colors.black),
            tooltip: l10n.savePdf,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
        useActions: false, // We use our own save action
        scrollViewDecoration: BoxDecoration(
          color: isDark ? AppColors.dark : AppColors.light,
        ),
      ),
    );
  }
}
