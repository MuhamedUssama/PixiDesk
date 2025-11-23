import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class CompressionResultWidget extends StatelessWidget {
  final PdfCompressionState state;

  const CompressionResultWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildFileDetails(
              context,
              title: l10n.originalFile,
              file: state.selectedFile!,
              isDark: isDark,
            ),
          ),
          const VerticalDivider(width: 32),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFileDetails(
                  context,
                  title: l10n.compressedFile,
                  file: state.compressedFile!,
                  isDark: isDark,
                  showRemove: false,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () async {
                    final outputPath = await FilePicker.platform.saveFile(
                      dialogTitle: l10n.saveAs,
                      fileName: state.compressedFile!.path
                          .split(Platform.pathSeparator)
                          .last,
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (outputPath != null) {
                      await state.compressedFile!.copy(outputPath);
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
                  child: Text(l10n.quickSave),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.pdfPreviewRoute,
                      arguments: state.compressedFile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 56),
                  ),
                  child: Text(l10n.previewAndSave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileDetails(
    BuildContext context, {
    required String title,
    required File file,
    required bool isDark,
    bool showRemove = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: isDark
              ? AppColors.darkHeadTextColor
              : AppColors.lightHeadTextColor,
        ),
        const SizedBox(height: 16),
        Text(
          file.path.split(Platform.pathSeparator).last,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(_formatBytes(file.lengthSync()), style: theme.textTheme.bodySmall),
        if (showRemove) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              context.read<PdfCompressionCubit>().clearFile();
            },
            icon: const Icon(Icons.close, color: AppColors.error),
            label: Text(
              l10n.removeFile,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    var value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
