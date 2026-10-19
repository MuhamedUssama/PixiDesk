import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';
import 'conversion_progress_widget.dart';

class SelectedFileState extends StatelessWidget {
  final PdfToImageState state;
  final AppLocalizations l10n;
  const SelectedFileState({super.key, required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: state.selectedFiles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = state.selectedFiles[index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaceColors.controlBackground,
                  borderRadius: BorderRadius.circular(
                    AppThemeMetrics.controlRadius,
                  ),
                  border: Border.all(color: surfaceColors.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 26,
                        color: surfaceColors.secondaryText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Tooltip(
                          message: document.path,
                          child: Text(
                            path.basename(document.path),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l10n.removeFile,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: state.isBusy
                            ? null
                            : () => context.read<PdfToImageBloc>().removeFile(
                                document,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (state.isBusy)
          const ConversionProgressWidget()
        else
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              key: const ValueKey('clearAllButton'),
              onPressed: () => context.read<PdfToImageBloc>().clearFile(),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(l10n.pdfClearAll),
            ),
          ),
      ],
    );
  }
}
