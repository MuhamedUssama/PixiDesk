import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/image_job.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import '../utils/image_labels.dart';
import 'image_studio_style.dart';

class ImageQueue extends StatelessWidget {
  const ImageQueue({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = StudioColors(context);
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final c = context.read<ImageCubit>();
        return StudioPanel(
          minimumContentHeight: 300,
          child: Focus(
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.delete &&
                  !state.busy) {
                c.removeSelected();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.imageStudioLibrary,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.field,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          state.jobs.length.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: l.imageStudioMore,
                        enabled: !state.busy,
                        icon: const Icon(Icons.more_horiz_rounded, size: 17),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'retry',
                            child: Text(l.imageRetryFailed),
                          ),
                          PopupMenuItem(
                            value: 'clear',
                            child: Text(l.imageClearQueue),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'retry') {
                            c.exportBatch(
                              l.imageOutputFolder,
                              failedOnly: true,
                            );
                          } else {
                            c.clearQueue();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.jobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 27,
                                  color: colors.faint,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  l.imageStudioQueueEmpty,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.muted,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  l.imageStudioQueuePrompt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.faint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: state.jobs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 5),
                          itemBuilder: (context, index) {
                            final job = state.jobs[index];
                            final selected = index == state.selectedIndex;
                            return Material(
                              color: selected
                                  ? colors.selected
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                                side: BorderSide(
                                  color: selected
                                      ? colors.ink.withValues(alpha: .12)
                                      : Colors.transparent,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(11),
                                onTap: state.busy
                                    ? null
                                    : () => c.selectImage(index),
                                onSecondaryTapDown: state.busy
                                    ? null
                                    : (details) => _actions(
                                        context,
                                        c,
                                        job,
                                        index,
                                        l,
                                        details.globalPosition,
                                      ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.memory(
                                          job.source.thumbnail,
                                          width: 42,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const SizedBox(
                                                width: 42,
                                                height: 45,
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job.source.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: selected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: colors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              imageSizeLabel(
                                                l,
                                                job.source.sizeInBytes,
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: colors.muted,
                                              ),
                                            ),
                                            if (job.status !=
                                                ImageJobStatus.pending) ...[
                                              const SizedBox(height: 3),
                                              Text(
                                                job.failure == null
                                                    ? imageStatusLabel(
                                                        l,
                                                        job.status,
                                                      )
                                                    : imageFailureLabel(
                                                        l,
                                                        job.failure!,
                                                      ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: job.failure == null
                                                      ? colors.muted
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.error,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (job.status == ImageJobStatus.running)
                                        const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                      else if (selected)
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                start: 4,
                                              ),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 13,
                                            color: colors.ink,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: OutlinedButton.icon(
                    onPressed: state.busy
                        ? null
                        : () => c.pickImages(l.imageAddFiles),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(l.imageAddFiles),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: colors.faint,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.imageStudioLocal,
                          maxLines: 2,
                          style: TextStyle(fontSize: 10, color: colors.faint),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _actions(
    BuildContext context,
    ImageCubit c,
    ImageJob job,
    int index,
    AppLocalizations l,
    Offset position,
  ) async {
    c.selectImage(index);
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        MediaQuery.sizeOf(context).width - position.dx,
        MediaQuery.sizeOf(context).height - position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        if (job.result != null && !job.result!.skipped) ...[
          PopupMenuItem(value: 'open', child: Text(l.imageOpen)),
          PopupMenuItem(value: 'reveal', child: Text(l.imageReveal)),
        ],
        PopupMenuItem(value: 'remove', child: Text(l.imageRemove)),
      ],
    );
    if (c.isClosed) return;
    if (action == 'remove') {
      c.removeSelected();
    } else if (action != null && job.result != null) {
      c.openFile(job.result!.path, reveal: action == 'reveal');
    }
  }
}
