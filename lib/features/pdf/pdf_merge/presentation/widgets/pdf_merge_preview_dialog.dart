import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_merge_action.dart';
import '../bloc/pdf_merge_bloc.dart';
import '../bloc/pdf_merge_state.dart';
import '../utils/pdf_merge_labels.dart';

class PdfMergePreviewDialog extends StatefulWidget {
  const PdfMergePreviewDialog({super.key});
  @override
  State<PdfMergePreviewDialog> createState() => _PdfMergePreviewDialogState();
}

class _PdfMergePreviewDialogState extends State<PdfMergePreviewDialog> {
  final FocusNode _previewFocus = FocusNode();
  bool _showPageList = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _previewFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _previewFocus.dispose();
    super.dispose();
  }

  void _navigate(PdfMergeState state, int delta) {
    final document = state.previewDocument;
    if (document == null || !state.canEdit) return;
    final page = (state.previewPageIndex + delta).clamp(
      0,
      document.pageCount - 1,
    );
    if (page != state.previewPageIndex) {
      context.read<PdfMergeBloc>().add(
        PdfMergePreviewRequested(document.id, page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bloc = context.read<PdfMergeBloc>();
    final colors = AppSurfaceColors.of(context);
    return Focus(
      focusNode: _previewFocus,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final keyboard = HardwareKeyboard.instance;
        if (keyboard.isControlPressed ||
            keyboard.isAltPressed ||
            keyboard.isMetaPressed ||
            keyboard.isShiftPressed) {
          return KeyEventResult.ignored;
        }
        final right = event.logicalKey == LogicalKeyboardKey.arrowRight;
        if (!right && event.logicalKey != LogicalKeyboardKey.arrowLeft) {
          return KeyEventResult.ignored;
        }
        _navigate(
          bloc.state,
          right == (Directionality.of(context) == TextDirection.rtl) ? -1 : 1,
        );
        return KeyEventResult.handled;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 1100,
          height: MediaQuery.sizeOf(context).height * .85,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<PdfMergeBloc, PdfMergeState>(
              builder: (context, state) {
                final document = state.previewDocument;
                if (document == null) return const SizedBox.shrink();
                final pageList = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      localizations.pdfMergeSelectedPages(
                        document.selectedPages.length,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: state.canEdit
                              ? () => bloc.add(
                                  PdfMergePagesChanged(
                                    document.id,
                                    List.generate(
                                      document.pageCount,
                                      (index) => index,
                                    ),
                                  ),
                                )
                              : null,
                          child: Text(localizations.pdfMergeSelectAll),
                        ),
                        TextButton(
                          onPressed: state.canEdit
                              ? () => bloc.add(
                                  PdfMergePagesChanged(document.id, []),
                                )
                              : null,
                          child: Text(localizations.pdfClearAll),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: document.selectedPages.length,
                        onReorderItem: (from, to) {
                          final pages = document.selectedPages.toList();
                          pages.insert(to, pages.removeAt(from));
                          bloc.add(PdfMergePagesChanged(document.id, pages));
                        },
                        itemBuilder: (context, index) {
                          final page = document.selectedPages[index];
                          return ListTile(
                            key: ValueKey('${document.id}-$index-$page'),
                            selected: page == state.previewPageIndex,
                            selectedTileColor: colors.selectedBackground,
                            contentPadding: EdgeInsets.zero,
                            leading: ReorderableDragStartListener(
                              index: index,
                              enabled: state.canEdit,
                              child: const Icon(Icons.drag_indicator_rounded),
                            ),
                            title: Text(
                              localizations.pdfMergePageNumber(page + 1),
                            ),
                            onTap: () => bloc.add(
                              PdfMergePreviewRequested(document.id, page),
                            ),
                            trailing: IconButton(
                              tooltip: localizations.pdfMergeRemovePage,
                              onPressed: state.canEdit
                                  ? () {
                                      final pages =
                                          document.selectedPages.toList()
                                            ..removeAt(index);
                                      bloc.add(
                                        PdfMergePagesChanged(
                                          document.id,
                                          pages,
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.close_rounded),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
                final included = document.selectedPages.contains(
                  state.previewPageIndex,
                );
                final preview = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.canvasBackground,
                          border: Border.all(color: colors.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: state.isPreviewLoading
                              ? const CircularProgressIndicator()
                              : state.previewFailure != null
                              ? Text(
                                  pdfMergeFailureLabel(
                                    localizations,
                                    state.previewFailure!,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : state.previewPath == null
                              ? const SizedBox.shrink()
                              : RotatedBox(
                                  quarterTurns:
                                      document.rotations[state
                                          .previewPageIndex] ??
                                      0,
                                  child: Image.file(
                                    File(state.previewPath!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stack) =>
                                        Text(
                                          localizations
                                              .pdfMergePreviewUnavailable,
                                          textAlign: TextAlign.center,
                                        ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        IconButton(
                          tooltip: localizations.previous,
                          onPressed: state.previewPageIndex > 0
                              ? () => _navigate(state, -1)
                              : null,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Text(
                          localizations.pdfPageIndicator(
                            state.previewPageIndex + 1,
                            document.pageCount,
                          ),
                        ),
                        IconButton(
                          tooltip: localizations.next,
                          onPressed:
                              state.previewPageIndex < document.pageCount - 1
                              ? () => _navigate(state, 1)
                              : null,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                        OutlinedButton.icon(
                          onPressed: state.canEdit
                              ? () => bloc.add(
                                  PdfMergePageRotated(
                                    document.id,
                                    pageIndex: state.previewPageIndex,
                                  ),
                                )
                              : null,
                          icon: const Icon(
                            Icons.rotate_right_rounded,
                            size: 18,
                          ),
                          label: Text(localizations.rotateRight),
                        ),
                        TextButton.icon(
                          onPressed: state.canEdit
                              ? () {
                                  final pages = document.selectedPages.toList();
                                  if (included) {
                                    pages.removeWhere(
                                      (page) => page == state.previewPageIndex,
                                    );
                                  } else {
                                    pages.add(state.previewPageIndex);
                                  }
                                  bloc.add(
                                    PdfMergePagesChanged(document.id, pages),
                                  );
                                }
                              : null,
                          icon: Icon(
                            included
                                ? Icons.check_circle_outline_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 18,
                          ),
                          label: Text(
                            included
                                ? localizations.pdfMergeIncluded
                                : localizations.pdfMergeIncludePage,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: localizations.pdfMergeArrangePages,
                          onPressed: () =>
                              setState(() => _showPageList = !_showPageList),
                          icon: const Icon(Icons.reorder_rounded),
                        ),
                        IconButton(
                          tooltip: localizations.pdfMergeClosePreview,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth < 700
                            ? (_showPageList ? pageList : preview)
                            : Row(
                                children: [
                                  SizedBox(width: 240, child: pageList),
                                  const SizedBox(width: 16),
                                  Expanded(child: preview),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
