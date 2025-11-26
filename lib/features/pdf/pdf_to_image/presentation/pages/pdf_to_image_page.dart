import 'dart:developer';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/conversion_progress_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/conversion_settings_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/empty_state_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/pdf_to_image_appbar.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/review_ui_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/selected_file_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const PdfToImageAppbar(),
      body: BlocConsumer<PdfToImageCubit, PdfToImageState>(
        listener: (context, state) {
          if (state.status == PdfToImageStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PdfToImageStatus.review &&
              state.generatedImages != null) {
            return ReviewUiWidget(
              state: state,
              l10n: l10n,
              onSaveAll: () => _saveAll(context, state.generatedImages!),
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: DropTarget(
                  onDragDone: (details) {
                    if (details.files.isNotEmpty) {
                      final file = File(details.files.first.path);
                      if (file.path.toLowerCase().endsWith('.pdf')) {
                        context.read<PdfToImageCubit>().selectFile(file);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.invalidPdfFile),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: state.selectedFile == null
                          ? EmptyStateWidget(l10n: l10n)
                          : SelectedFileState(state: state, l10n: l10n),
                    ),
                  ),
                ),
              ),
              if (state.selectedFile != null)
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      const ConversionSettingsWidget(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: state.status == PdfToImageStatus.converting
                              ? const ConversionProgressWidget()
                              : ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<PdfToImageCubit>()
                                        .startConversion();
                                  },
                                  child: Text(l10n.convert),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveAll(BuildContext context, List<File> files) async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      // Copy files to directory
      try {
        for (final file in files) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          await file.copy('$directoryPath${Platform.pathSeparator}$fileName');
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.filesSaved),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          log('Error saving files: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving files'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
