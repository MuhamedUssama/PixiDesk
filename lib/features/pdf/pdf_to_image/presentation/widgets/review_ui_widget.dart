import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';
import '../utils/pdf_export_options_dialog.dart';
import 'image_grid_view.dart';
import 'image_page_view.dart';

class ReviewUiWidget extends StatefulWidget {
  final PdfToImageState state;
  final AppLocalizations l10n;
  const ReviewUiWidget({super.key, required this.state, required this.l10n});

  @override
  State<ReviewUiWidget> createState() => _ReviewUiWidgetState();
}

class _ReviewUiWidgetState extends State<ReviewUiWidget> {
  bool _isGridView = true;
  int _initialPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.state.generatedImages;
    if (images == null || images.isEmpty) return const SizedBox.shrink();
    final surfaceColors = AppSurfaceColors.of(context);
    final bloc = context.read<PdfToImageBloc>();
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: widget.l10n.imageFromPdf,
          icon: const Icon(Icons.tune_rounded),
          onPressed: widget.state.isBusy
              ? null
              : () => Navigator.of(context).pushNamed(
                  AppRouter.imageProcessingRoute,
                  arguments: images
                      .where(
                        (file) =>
                            widget.state.selectedImagePaths.isEmpty ||
                            widget.state.selectedImagePaths.contains(file.path),
                      )
                      .map((file) => file.path)
                      .toList(),
                ),
        ),
        if (!_isGridView)
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: widget.l10n.gridView,
            onPressed: () => setState(() => _isGridView = true),
          ),
        if (_isGridView && widget.state.selectedImagePaths.isNotEmpty)
          OutlinedButton.icon(
            onPressed: widget.state.isBusy ? null : bloc.deleteSelectedImages,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(widget.l10n.deleteSelected),
          ),
        OutlinedButton.icon(
          onPressed: widget.state.isBusy
              ? null
              : () => bloc.saveAsZip(widget.l10n.pdfSaveZipTitle),
          icon: const Icon(Icons.archive_outlined, size: 18),
          label: Text(widget.l10n.saveAsZip),
        ),
        FilledButton.icon(
          onPressed: widget.state.isBusy
              ? null
              : () => PdfExportOptionsDialog.show(
                  context: context,
                  bloc: bloc,
                  l10n: widget.l10n,
                  isMultipleFiles: widget.state.selectedFiles.length > 1,
                ),
          icon: const Icon(Icons.save_alt_rounded, size: 18),
          label: Text(widget.l10n.saveAll),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 850;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 16 : 32,
            16,
            isCompact ? 16 : 32,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.l10n.conversionResult,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    actions,
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.l10n.conversionResult,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: _isGridView
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: surfaceColors.canvasBackground,
                          border: Border.all(color: surfaceColors.borderColor),
                          borderRadius: BorderRadius.circular(
                            AppThemeMetrics.cardRadius,
                          ),
                        ),
                        child: ImageGridView(
                          images: images,
                          onImageTap: (pageIndex) => setState(() {
                            _initialPageIndex = pageIndex;
                            _isGridView = false;
                          }),
                        ),
                      )
                    : ImagePageView(
                        images: images,
                        initialIndex: _initialPageIndex,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
