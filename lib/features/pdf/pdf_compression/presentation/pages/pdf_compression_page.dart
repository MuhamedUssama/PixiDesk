import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/image_processing/presentation/widgets/drop_zone_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/widgets/compression_settings.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/widgets/empty_compress_pdf_state_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/widgets/selected_files_widget.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

import '../widgets/compress_pdf_appbar.dart';

class PdfCompressionPage extends StatelessWidget {
  const PdfCompressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const CompressPdfAppbar(),
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
                        ? const EmptyCompressPdfStateWidget()
                        : SelectedFilesWidget(state: state),
                  ),
                ),
                if (state.selectedFile != null) ...[
                  const SizedBox(height: 16),
                  CompressionSettings(state: state, l10n: l10n),
                  const SizedBox(height: 16),
                  ElevatedButton(
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
                    child: Text(l10n.compressPdf),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
