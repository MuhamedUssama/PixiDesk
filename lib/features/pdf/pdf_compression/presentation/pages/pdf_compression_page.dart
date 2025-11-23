import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/image_processing/presentation/widgets/drop_zone_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfCompressionPage extends StatelessWidget {
  const PdfCompressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.compressPdf),
        centerTitle: true,
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
      ),
      body: BlocConsumer<PdfCompressionCubit, PdfCompressionState>(
        listener: (context, state) {
          if (state.status == PdfCompressionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.error),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == PdfCompressionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.compressionSuccess),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PdfCompressionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: DropZoneWidget(
                    onDropped: (files) {
                      if (files.isNotEmpty &&
                          files.first.path.toLowerCase().endsWith('.pdf')) {
                        context.read<PdfCompressionCubit>().selectFile(
                          files.first,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.invalidPdfFile),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    child: state.selectedFile == null
                        ? _buildEmptyState(context, l10n)
                        : _buildSelectedFileState(context, state, l10n, isDark),
                  ),
                ),
                if (state.selectedFile != null) ...[
                  const SizedBox(height: 16),
                  _buildCompressionSettings(context, state, l10n),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final outputPath = await FilePicker.platform.saveFile(
                          dialogTitle: l10n.saveAs,
                          fileName:
                              'compressed_${state.selectedFile!.path.split(Platform.pathSeparator).last}',
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (outputPath != null && context.mounted) {
                          context.read<PdfCompressionCubit>().compressPdf(
                            outputPath,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.compressPdf),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dragDropPdf,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null &&
                  result.files.single.path != null &&
                  context.mounted) {
                context.read<PdfCompressionCubit>().selectFile(
                  File(result.files.single.path!),
                );
              }
            },
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.selectPdf),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileState(
    BuildContext context,
    PdfCompressionState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark : AppColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            state.selectedFile!.path.split(Platform.pathSeparator).last,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatBytes(state.selectedFile!.lengthSync()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
      ),
    );
  }

  Widget _buildCompressionSettings(
    BuildContext context,
    PdfCompressionState state,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.compressionLevel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CompressionLevel>(
              value: state.compressionLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: CompressionLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(_getCompressionLevelName(level, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<PdfCompressionCubit>().changeCompressionLevel(
                    value,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCompressionLevelName(
    CompressionLevel level,
    AppLocalizations l10n,
  ) {
    switch (level) {
      case CompressionLevel.screen:
        return l10n.compressionScreen;
      case CompressionLevel.ebook:
        return l10n.compressionEbook;
      case CompressionLevel.printer:
        return l10n.compressionPrinter;
      case CompressionLevel.prepress:
        return l10n.compressionPrepress;
      case CompressionLevel.defaultCompression:
        return l10n.compressionDefault;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    // 1024 is 1 << 10
    var value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
