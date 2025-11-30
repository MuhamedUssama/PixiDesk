import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/conversion_progress_widget.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class SelectedFileState extends StatelessWidget {
  final PdfToImageState state;
  final AppLocalizations l10n;
  const SelectedFileState({super.key, required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.picture_as_pdf,
          size: 64,
          color: isDark
              ? AppColors.darkHeadTextColor
              : AppColors.lightHeadTextColor,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        if (state.selectedFiles.length == 1)
          Text(
                state.selectedFiles.first.path
                    .split(Platform.pathSeparator)
                    .last,
                style: Theme.of(context).textTheme.headlineSmall,
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(
                begin: 0.5,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutQuad,
              )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.selectedFiles.length,
              itemBuilder: (context, index) {
                final file = state.selectedFiles[index];
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf, size: 24),
                  title: Text(
                    file.path.split(Platform.pathSeparator).last,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        context.read<PdfToImageCubit>().removeFile(file),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.status == PdfToImageStatus.converting
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: const ConversionProgressWidget(),
                )
              : TextButton.icon(
                  key: const ValueKey('clearAllButton'),
                  onPressed: () => context.read<PdfToImageCubit>().clearFile(),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                  label: const Text('Clear All'),
                ),
        ),
      ],
    );
  }
}
