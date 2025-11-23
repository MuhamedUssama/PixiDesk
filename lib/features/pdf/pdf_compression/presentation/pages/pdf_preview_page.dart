import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import 'package:printing/printing.dart';

class PdfPreviewArgs {
  final File file;
  final PdfCompressionCubit cubit;

  PdfPreviewArgs({required this.file, required this.cubit});
}

class PdfPreviewPage extends StatefulWidget {
  final File pdfFile;

  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfCompressionCubit>().loadPreviewBytes(widget.pdfFile);
    });
  }

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
              String? outputPath = await FilePicker.platform.saveFile(
                dialogTitle: l10n.saveAs,
                fileName: widget.pdfFile.path
                    .split(Platform.pathSeparator)
                    .last,
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (outputPath != null) {
                if (!outputPath.toLowerCase().endsWith('.pdf')) {
                  outputPath = '$outputPath.pdf';
                }

                await widget.pdfFile.copy(outputPath);
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
      body: BlocBuilder<PdfCompressionCubit, PdfCompressionState>(
        builder: (context, state) {
          if (state.previewStatus == PdfCompressionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.previewStatus == PdfCompressionStatus.success &&
              state.previewBytes != null) {
            return PdfPreview(
              build: (format) => state.previewBytes!,
              useActions: false,
              scrollViewDecoration: BoxDecoration(
                color: isDark ? AppColors.dark : AppColors.light,
              ),
            );
          } else if (state.previewStatus == PdfCompressionStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? l10n.error,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
