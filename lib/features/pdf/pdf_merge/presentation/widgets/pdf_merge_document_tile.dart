import 'package:flutter/material.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/pdf_merge_document.dart';
import '../bloc/pdf_merge_state.dart';
import '../utils/pdf_merge_labels.dart';

class PdfMergeDocumentTile extends StatefulWidget {
  final PdfMergeDocument document;
  final int index;
  final PdfMergeState state;
  final VoidCallback onPreview;
  final VoidCallback onRemove;
  final VoidCallback onMoveEarlier;
  final VoidCallback onMoveLater;
  final VoidCallback onRotateSelectedPages;
  final ValueChanged<String> onPageRangeChanged;
  const PdfMergeDocumentTile({
    super.key,
    required this.document,
    required this.index,
    required this.state,
    required this.onPreview,
    required this.onRemove,
    required this.onMoveEarlier,
    required this.onMoveLater,
    required this.onRotateSelectedPages,
    required this.onPageRangeChanged,
  });
  @override
  State<PdfMergeDocumentTile> createState() => _PdfMergeDocumentTileState();
}

class _PdfMergeDocumentTileState extends State<PdfMergeDocumentTile> {
  late final TextEditingController _rangeController;
  final FocusNode _rangeFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _rangeController = TextEditingController(
      text: formatPdfPageRange(widget.document.selectedPages),
    );
  }

  @override
  void didUpdateWidget(covariant PdfMergeDocumentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_rangeFocus.hasFocus &&
        oldWidget.document.selectedPages != widget.document.selectedPages) {
      _rangeController.text = formatPdfPageRange(widget.document.selectedPages);
    }
  }

  @override
  void dispose() {
    _rangeController.dispose();
    _rangeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = AppSurfaceColors.of(context);
    final document = widget.document;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.controlBackground,
        border: Border.all(color: colors.borderColor),
        borderRadius: BorderRadius.circular(AppThemeMetrics.controlRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                enabled: widget.state.canEdit,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: colors.secondaryText,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: document.path,
                      child: Text(
                        document.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.pdfMergeFileDetails(
                        document.pageCount,
                        (document.sizeBytes / (1024 * 1024)).toStringAsFixed(1),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: localizations.removeFile,
                onPressed: widget.state.canEdit ? widget.onRemove : null,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: ValueKey('range-${document.id}'),
            controller: _rangeController,
            focusNode: _rangeFocus,
            enabled: widget.state.canEdit,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: localizations.pdfMergePageRange,
              hintText: localizations.pdfMergeRangeHint,
              errorText:
                  widget.state.invalidRangeDocumentIds.contains(document.id)
                  ? localizations.pdfMergeInvalidRange
                  : null,
            ),
            onChanged: widget.onPageRangeChanged,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed:
                    widget.state.canEdit &&
                        !widget.state.invalidRangeDocumentIds.contains(
                          document.id,
                        )
                    ? widget.onPreview
                    : null,
                icon: const Icon(Icons.preview_outlined, size: 18),
                label: Text(localizations.pdfMergeArrangePages),
              ),
              IconButton(
                tooltip: localizations.pdfMergeMoveEarlier,
                onPressed: widget.state.canEdit && widget.index > 0
                    ? widget.onMoveEarlier
                    : null,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                tooltip: localizations.pdfMergeMoveLater,
                onPressed:
                    widget.state.canEdit &&
                        widget.index < widget.state.documents.length - 1
                    ? widget.onMoveLater
                    : null,
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                tooltip: localizations.rotateRight,
                onPressed:
                    widget.state.canEdit && document.selectedPages.isNotEmpty
                    ? widget.onRotateSelectedPages
                    : null,
                icon: const Icon(Icons.rotate_right_rounded),
              ),
              Text(
                localizations.pdfMergeSelectedPages(
                  document.selectedPages.length,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
