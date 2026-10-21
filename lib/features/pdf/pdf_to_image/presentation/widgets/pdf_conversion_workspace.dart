import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../core/widgets/drop_zone_widget.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';
import 'conversion_settings_widget.dart';
import 'empty_state_widget.dart';
import 'selected_file_state.dart';

class PdfConversionWorkspace extends StatelessWidget {
  final PdfToImageState state;
  const PdfConversionWorkspace({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final surfaceColors = AppSurfaceColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 850;
        final pagePadding = isCompact
            ? AppThemeMetrics.compactPagePadding
            : AppThemeMetrics.pagePadding;
        final documentsPanel = DropZoneWidget(
          enabled: !state.isBusy,
          onDropped: (files) => context.read<PdfToImageBloc>().selectFiles(
            files
                .where((file) => file.path.toLowerCase().endsWith('.pdf'))
                .toList(),
          ),
          child: Card(
            key: const ValueKey('pdfDocumentsPanel'),
            child: Padding(
              padding: const EdgeInsets.all(AppThemeMetrics.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        localizations.pdfDocuments,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.selectedFiles.isNotEmpty)
                        Chip(
                          label: Text(
                            localizations.pdfDocumentCount(
                              state.selectedFiles.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.selectedFiles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: EmptyStateWidget(l10n: localizations),
                    )
                  else ...[
                    SelectedFileState(state: state, l10n: localizations),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: surfaceColors.controlBackground,
                        border: Border.all(color: surfaceColors.borderColor),
                        borderRadius: BorderRadius.circular(
                          AppThemeMetrics.controlRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: surfaceColors.secondaryText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizations.pdfDropMoreDocuments,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(pagePadding),
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppThemeMetrics.pageMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.pdfExtractAction,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.pdfExtractDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: surfaceColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppThemeMetrics.sectionGap),
                  if (isCompact) ...[
                    documentsPanel,
                    const SizedBox(height: AppThemeMetrics.cardGap),
                    const ConversionSettingsWidget(),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: documentsPanel),
                        const SizedBox(width: AppThemeMetrics.cardGap),
                        const SizedBox(
                          width: 320,
                          child: ConversionSettingsWidget(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
