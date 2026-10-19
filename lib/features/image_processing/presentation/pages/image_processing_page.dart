import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/drop_zone_widget.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import '../utils/image_labels.dart';
import '../widgets/control_panel.dart';
import '../widgets/image_preview.dart';
import '../widgets/image_queue.dart';
import '../widgets/image_processing_appbar.dart';
import '../widgets/image_studio_style.dart';

class ImageProcessingPage extends StatelessWidget {
  const ImageProcessingPage({super.key});
  @override
  Widget build(BuildContext context) =>
      ImageStudioTheme(child: Builder(builder: _buildWorkspace));

  Widget _buildWorkspace(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.read<ImageCubit>();
    final colors = StudioColors(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
            c.pickImages(l.imageAddFiles),
        const SingleActivator(LogicalKeyboardKey.keyO, meta: true): () =>
            c.pickImages(l.imageAddFiles),
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
          shift: true,
        ): () =>
            c.exportImage(l.imageExportTitle),
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          meta: true,
          shift: true,
        ): () =>
            c.exportImage(l.imageExportTitle),
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
            _paste(c),
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true): () =>
            _paste(c),
        const SingleActivator(LogicalKeyboardKey.escape): c.cancel,
      },
      child: Focus(
        autofocus: true,
        child: BlocConsumer<ImageCubit, ImageState>(
          listenWhen: (previous, current) =>
              previous.messageId != current.messageId,
          listener: (context, state) {
            if (state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(imageFailureLabel(l, state.failure!)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) => Scaffold(
            appBar: ImageProcessingAppbar(
              actions: [
                IconButton(
                  tooltip: l.imageHistory,
                  onPressed: () => _history(context, c, l),
                  icon: const Icon(Icons.history_rounded),
                ),
                IconButton(
                  tooltip: l.imageTools,
                  onPressed: () => _tools(context, c, l),
                  icon: const Icon(Icons.auto_awesome_outlined),
                ),
                PopupMenuButton<String>(
                  tooltip: l.imageStudioMore,
                  icon: const Icon(Icons.more_horiz_rounded, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) => _menu(context, value, state, c, l),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'watch',
                      enabled: !state.busy,
                      child: Text(
                        state.watching ? l.imageStopWatch : l.imageWatch,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pdf',
                      enabled: !state.busy && state.jobs.isNotEmpty,
                      child: Text(l.imageToPdf),
                    ),
                    PopupMenuItem(
                      value: 'assets',
                      enabled: !state.busy && state.selectedImage != null,
                      child: Text(l.imageAssetScales),
                    ),
                  ],
                ),
              ],
            ),
            body: DropZoneWidget(
              enabled: !state.busy,
              onDropped: (files) =>
                  c.addImages(files.map((f) => f.path).toList()),
              child: Column(
                children: [
                  _toolbar(context, state, c, l),
                  if (state.busy || state.watching)
                    _activity(context, state, c, l),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final padding = constraints.maxWidth < 900
                            ? 12.0
                            : 20.0;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            padding,
                            0,
                            padding,
                            padding,
                          ),
                          child: constraints.maxWidth < 900
                              ? DefaultTabController(
                                  length: 3,
                                  initialIndex: 1,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colors.field,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: TabBar(
                                          labelColor: colors.ink,
                                          unselectedLabelColor: colors.muted,
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          dividerColor: Colors.transparent,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicator: BoxDecoration(
                                            color: colors.panel,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          tabs: [
                                            Tab(height: 32, text: l.imageQueue),
                                            Tab(
                                              height: 32,
                                              text: l.imagePreview,
                                            ),
                                            Tab(
                                              height: 32,
                                              text: l.imageSettings,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Expanded(
                                        child: TabBarView(
                                          children: [
                                            ImageQueue(),
                                            ImagePreview(),
                                            ControlPanel(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (constraints.maxWidth >= 1150) ...[
                                      const SizedBox(
                                        width: 208,
                                        child: ImageQueue(),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    const Expanded(child: ImagePreview()),
                                    const SizedBox(width: 16),
                                    const SizedBox(
                                      width: 328,
                                      child: ControlPanel(),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _paste(ImageCubit cubit) {
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus != null && Actions.maybeFind<PasteTextIntent>(focus) != null) {
      Actions.invoke(
        focus,
        const PasteTextIntent(SelectionChangedCause.keyboard),
      );
    } else {
      cubit.pasteImages();
    }
  }

  Widget _toolbar(
    BuildContext context,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) {
    final colors = StudioColors(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 20,
            0,
            compact ? 12 : 20,
            16,
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: state.busy
                    ? null
                    : () => c.pickImages(l.imageAddFiles),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.imageAddFiles),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                enabled: !state.busy,
                tooltip: l.imageStudioImportOptions,
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'paste') {
                    c.pasteImages();
                  } else {
                    c.addFolder(
                      l.imageAddFolder,
                      recursive: value == 'recursive',
                    );
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'folder', child: Text(l.imageAddFolder)),
                  PopupMenuItem(
                    value: 'recursive',
                    child: Text(l.imageAddRecursive),
                  ),
                  PopupMenuItem(value: 'paste', child: Text(l.imagePaste)),
                ],
              ),
              if (!compact) ...[
                Container(
                  width: 1,
                  height: 20,
                  color: colors.line,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                IconButton(
                  tooltip: l.imageUndo,
                  onPressed: state.busy || !state.canUndo ? null : c.undo,
                  icon: const Icon(Icons.undo_rounded),
                ),
                IconButton(
                  tooltip: l.imageRedo,
                  onPressed: state.busy || !state.canRedo ? null : c.redo,
                  icon: const Icon(Icons.redo_rounded),
                ),
              ],
              const Spacer(),
              if (constraints.maxWidth >= 900 && constraints.maxWidth < 1150)
                IconButton(
                  tooltip: l.imageQueue,
                  onPressed: () => _queue(context, c, l),
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              if (constraints.maxWidth > 1000) ...[
                Text(
                  l.imageQueueCount(state.jobs.length),
                  style: TextStyle(fontSize: 11, color: colors.muted),
                ),
                const SizedBox(width: 18),
              ],
              FilledButton.icon(
                onPressed: state.busy || state.jobs.isEmpty
                    ? null
                    : () => c.exportBatch(l.imageOutputFolder),
                icon: const Icon(Icons.arrow_outward_rounded, size: 17),
                label: Text(l.imageStudioExportAll),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _activity(
    BuildContext context,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) {
    final colors = StudioColors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: StudioPanel(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    state.busy
                        ? Icons.hourglass_top_rounded
                        : Icons.visibility_outlined,
                    size: 15,
                    color: colors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.busy
                          ? imageOperationLabel(l, state.operation)
                          : l.imageWatchingPath(state.watchFolder ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (state.operation == ImageOperation.exporting &&
                      state.total > 0) ...[
                    Text(
                      l.imageProgressCount(state.finished, state.total),
                      style: TextStyle(fontSize: 11, color: colors.muted),
                    ),
                    IconButton(
                      tooltip: state.paused ? l.imageResume : l.imagePause,
                      onPressed: c.togglePause,
                      icon: Icon(
                        state.paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                      ),
                    ),
                  ],
                  if (state.busy)
                    IconButton(
                      tooltip: l.cancel,
                      onPressed: c.cancel,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  if (!state.busy && state.watching)
                    IconButton(
                      tooltip: l.imageStopWatch,
                      onPressed: c.stopWatching,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
            if (state.busy)
              LinearProgressIndicator(
                minHeight: 2,
                value:
                    state.operation == ImageOperation.exporting &&
                        state.total > 0
                    ? state.finished / state.total
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _queue(BuildContext context, ImageCubit c, AppLocalizations l) =>
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 340,
            height: 520,
            child: BlocProvider.value(value: c, child: const ImageQueue()),
          ),
        ),
      );

  Future<void> _menu(
    BuildContext context,
    String value,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) async {
    if (value == 'watch') {
      if (state.watching) {
        await c.stopWatching();
      } else {
        final accepted = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.imageWatch),
            content: Text(l.imageWatchHint),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.imageWatch),
              ),
            ],
          ),
        );
        if (accepted == true && !c.isClosed) {
          await c.startWatching(l.imageWatchInput, l.imageOutputFolder);
        }
      }
    } else if (value == 'pdf' && context.mounted) {
      final paths = state.jobs
          .map(
            (j) => j.result != null && !j.result!.skipped
                ? j.result!.path
                : j.source.path,
          )
          .toList();
      await Navigator.of(
        context,
      ).pushNamed(AppRouter.pdfConverterRoute, arguments: paths);
    } else if (value == 'assets') {
      await c.exportAssetScales(l.imageOutputFolder);
    }
  }

  Future<void> _history(
    BuildContext context,
    ImageCubit c,
    AppLocalizations l,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: c,
        child: BlocBuilder<ImageCubit, ImageState>(
          builder: (ctx, state) => AlertDialog(
            title: Text(l.imageHistory),
            content: SizedBox(
              width: 650,
              height: 440,
              child: Column(
                children: [
                  Text(l.imageHistoryHint),
                  const SizedBox(height: 12),
                  Expanded(
                    child: (state.history.isEmpty && state.recovery.isEmpty)
                        ? Center(child: Text(l.imageEmptyHistory))
                        : ListView.builder(
                            itemCount:
                                state.recovery.length + state.history.length,
                            itemBuilder: (context, index) {
                              final entries = [
                                ...state.recovery,
                                ...state.history,
                              ];
                              final entry = entries[index];
                              return ListTile(
                                title: Text(
                                  entry.outputPath,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  index < state.recovery.length
                                      ? l.imageInterrupted
                                      : MaterialLocalizations.of(
                                          context,
                                        ).formatFullDate(
                                          entry.createdAt.toLocal(),
                                        ),
                                ),
                                onTap: () =>
                                    c.openFile(entry.outputPath, reveal: true),
                                trailing: IconButton(
                                  tooltip: l.imageRestore,
                                  onPressed: state.busy
                                      ? null
                                      : () {
                                          Navigator.pop(ctx);
                                          c.restoreHistory(entry);
                                        },
                                  icon: const Icon(Icons.restore),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: state.busy ? null : c.clearHistory,
                child: Text(l.imageClearHistory),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tools(
    BuildContext context,
    ImageCubit c,
    AppLocalizations l,
  ) async {
    var language = Localizations.localeOf(context).languageCode == 'ar'
        ? 'ara+eng'
        : 'eng';
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: c,
        child: StatefulBuilder(
          builder: (ctx, setLocal) => BlocBuilder<ImageCubit, ImageState>(
            builder: (ctx, state) => AlertDialog(
              title: Text(l.imageTools),
              content: SizedBox(
                width: 600,
                height: 450,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l.imageOcrHint),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: language,
                        decoration: InputDecoration(
                          labelText: l.imageOcrLanguage,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'eng',
                            child: Text(l.imageEnglish),
                          ),
                          DropdownMenuItem(
                            value: 'ara',
                            child: Text(l.imageArabic),
                          ),
                          DropdownMenuItem(
                            value: 'ara+eng',
                            child: Text(l.imageArabicEnglish),
                          ),
                        ],
                        onChanged: state.busy
                            ? null
                            : (v) {
                                if (v != null) setLocal(() => language = v);
                              },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: state.busy || state.selectedImage == null
                            ? null
                            : () => c.recognizeText(language),
                        child: Text(l.imageOcr),
                      ),
                      if (state.recognizedText != null) ...[
                        SelectableText(state.recognizedText!),
                        Wrap(
                          children: [
                            TextButton(
                              onPressed: () => Clipboard.setData(
                                ClipboardData(text: state.recognizedText!),
                              ),
                              child: Text(l.imageCopyText),
                            ),
                            TextButton(
                              onPressed: state.busy
                                  ? null
                                  : () => c.saveRecognizedText(l.imageSaveText),
                              child: Text(l.imageSaveText),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Text(l.imageCutoutHint),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: state.busy || state.selectedImage == null
                            ? null
                            : c.removeBackground,
                        child: Text(l.imageCutout),
                      ),
                      if (state.busy) ...[
                        Text(imageOperationLabel(l, state.operation)),
                        const LinearProgressIndicator(),
                        TextButton(onPressed: c.cancel, child: Text(l.cancel)),
                      ],
                      if (state.failure != null)
                        Text(imageFailureLabel(l, state.failure!)),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
