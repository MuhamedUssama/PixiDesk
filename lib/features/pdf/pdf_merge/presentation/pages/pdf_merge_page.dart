import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../core/widgets/drop_zone_widget.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_merge_action.dart';
import '../bloc/pdf_merge_bloc.dart';
import '../bloc/pdf_merge_state.dart';
import '../utils/pdf_merge_labels.dart';
import '../widgets/pdf_merge_document_tile.dart';
import '../widgets/pdf_merge_preview_dialog.dart';

class PdfMergePage extends StatelessWidget {
  const PdfMergePage({super.key});
  Future<void> _requestPassword(
    BuildContext context,
    PdfMergeState state,
  ) async {
    final bloc = context.read<PdfMergeBloc>();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => _PdfMergePasswordDialog(
        filename: path.basename(state.passwordPath!),
        showError: state.failure != null,
      ),
    );
    if (!context.mounted || bloc.isClosed) return;
    if (password == null) {
      bloc.add(const PdfMergePasswordDismissed());
    } else {
      bloc.add(
        PdfMergeImportRequested([
          state.passwordPath!,
          ...state.pendingImportPaths,
        ], password: password),
      );
    }
  }

  Future<void> _showPreview(BuildContext context, String documentId) async {
    final bloc = context.read<PdfMergeBloc>();
    bloc.add(PdfMergePreviewRequested(documentId, 0));
    await showDialog<void>(
      context: context,
      builder: (context) =>
          BlocProvider.value(value: bloc, child: const PdfMergePreviewDialog()),
    );
    if (!bloc.isClosed) bloc.add(const PdfMergePreviewClosed());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = AppSurfaceColors.of(context);
    final bloc = context.read<PdfMergeBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(localizations.pdfMergeTitle)),
      body: BlocConsumer<PdfMergeBloc, PdfMergeState>(
        listenWhen: (previous, current) =>
            previous.messageId != current.messageId ||
            previous.passwordPath != current.passwordPath,
        listener: (context, state) {
          if (state.passwordPath != null) {
            _requestPassword(context, state);
          } else if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  pdfMergeFailureLabel(localizations, state.failure!),
                ),
              ),
            );
          }
        },
        builder: (context, state) => DropZoneWidget(
          enabled: state.canEdit,
          onDropped: (files) => bloc.add(
            PdfMergeImportRequested(
              files
                  .where((file) => file.path.toLowerCase().endsWith('.pdf'))
                  .map((file) => file.path)
                  .toList(),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 850;
              final documents = Card(
                key: const ValueKey('mergeDocumentsPanel'),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            localizations.pdfDocuments,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (state.documents.isNotEmpty)
                                TextButton(
                                  onPressed: state.canEdit
                                      ? () => bloc.add(
                                          const PdfMergeDocumentsCleared(),
                                        )
                                      : null,
                                  child: Text(localizations.pdfClearAll),
                                ),
                              OutlinedButton.icon(
                                onPressed: state.canEdit
                                    ? () => bloc.add(
                                        const PdfMergePickRequested(),
                                      )
                                    : null,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(localizations.pdfMergeAddDocuments),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (state.documents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 44,
                                color: colors.secondaryText,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.pdfMergeDropHint,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: state.documents.length,
                          onReorderItem: (from, to) =>
                              bloc.add(PdfMergeDocumentMoved(from, to)),
                          itemBuilder: (context, index) => PdfMergeDocumentTile(
                            key: ValueKey(state.documents[index].id),
                            document: state.documents[index],
                            index: index,
                            state: state,
                            onRemove: () => bloc.add(
                              PdfMergeDocumentRemoved(
                                state.documents[index].id,
                              ),
                            ),
                            onMoveEarlier: () => bloc.add(
                              PdfMergeDocumentMoved(index, index - 1),
                            ),
                            onMoveLater: () => bloc.add(
                              PdfMergeDocumentMoved(index, index + 1),
                            ),
                            onRotateSelectedPages: () => bloc.add(
                              PdfMergePageRotated(state.documents[index].id),
                            ),
                            onPageRangeChanged: (value) => bloc.add(
                              PdfMergeRangeEdited(
                                state.documents[index].id,
                                value,
                              ),
                            ),
                            onPreview: () => _showPreview(
                              context,
                              state.documents[index].id,
                            ),
                          ),
                        ),
                      Text(
                        localizations.pdfMergeOrderHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
              final settings = Card(
                key: const ValueKey('mergeSummaryPanel'),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localizations.pdfMergeSummary,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.pdfMergeDocumentSummary(
                          state.documents.length,
                          state.totalPages,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        localizations.pdfMergeStructureNotice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: state.acknowledgeDocumentChanges,
                        onChanged: state.canEdit
                            ? (value) => bloc.add(
                                PdfMergeAcknowledgementChanged(value ?? false),
                              )
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          localizations.pdfMergeAcknowledge,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.isBusy &&
                          state.status != PdfMergeStatus.picking) ...[
                        Text(
                          state.status == PdfMergeStatus.cancelling
                              ? localizations.pdfCancelling
                              : state.status == PdfMergeStatus.importing
                              ? localizations.pdfMergeInspecting
                              : pdfMergeStageLabel(localizations, state.stage),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: state.progress),
                        const SizedBox(height: 16),
                      ],
                      FilledButton.icon(
                        onPressed: state.canMerge
                            ? () => bloc.add(
                                PdfMergeRequested(
                                  localizations.pdfMergeSaveTitle,
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.merge_rounded, size: 18),
                        label: Text(localizations.pdfMergeAction),
                      ),
                      if (state.status == PdfMergeStatus.importing ||
                          state.status == PdfMergeStatus.merging ||
                          state.status == PdfMergeStatus.cancelling) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: state.status == PdfMergeStatus.cancelling
                              ? null
                              : () => bloc.add(const PdfMergeCancelRequested()),
                          child: Text(localizations.cancel),
                        ),
                      ],
                      if (state.result case final result?) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          localizations.pdfMergeSuccess,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Tooltip(
                          message: result.path,
                          child: Text(
                            path.basename(result.path),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.pdfMergeFileDetails(
                            result.pageCount,
                            (result.sizeBytes / (1024 * 1024)).toStringAsFixed(
                              1,
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  bloc.add(const PdfMergeOutputOpened()),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                              ),
                              label: Text(localizations.pdfMergeOpenResult),
                            ),
                            TextButton(
                              onPressed: () => bloc.add(
                                const PdfMergeOutputOpened(reveal: true),
                              ),
                              child: Text(localizations.pdfMergeRevealResult),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
              return SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 20 : 32),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppThemeMetrics.pageMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.pdfMergeTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.pdfMergeDescription,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.secondaryText),
                        ),
                        const SizedBox(height: 32),
                        if (compact) ...[
                          documents,
                          const SizedBox(height: 16),
                          settings,
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: documents),
                              const SizedBox(width: 16),
                              SizedBox(width: 320, child: settings),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PdfMergePasswordDialog extends StatefulWidget {
  final String filename;
  final bool showError;
  const _PdfMergePasswordDialog({
    required this.filename,
    required this.showError,
  });
  @override
  State<_PdfMergePasswordDialog> createState() =>
      _PdfMergePasswordDialogState();
}

class _PdfMergePasswordDialogState extends State<_PdfMergePasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _passwordController.clear();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.pdfMergePasswordTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.filename, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              autofocus: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: localizations.pdfMergePasswordLabel,
                errorText: widget.showError
                    ? localizations.pdfMergePasswordRejected
                    : null,
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _passwordController.text),
          child: Text(localizations.pdfMergeUnlock),
        ),
      ],
    );
  }
}
