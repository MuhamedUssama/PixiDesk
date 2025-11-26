import 'dart:io';

import 'package:flutter/material.dart';
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
        ),
        const SizedBox(height: 16),
        Text(
          state.selectedFile!.path.split(Platform.pathSeparator).last,
          style: Theme.of(context).textTheme.headlineSmall,
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
                  key: const ValueKey('removeButton'),
                  onPressed: () => context.read<PdfToImageCubit>().clearFile(),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: Text(l10n.removeFile),
                ),
        ),
      ],
    );
  }
}
