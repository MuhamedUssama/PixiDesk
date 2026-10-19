import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/image_geometry.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import '../utils/image_labels.dart';
import 'image_studio_style.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({super.key});
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final _transform = TransformationController();
  int _view = 1;
  String? _sourcePath;
  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final scale = (_transform.value.getMaxScaleOnAxis() * factor).clamp(
      .5,
      8.0,
    );
    _transform.value = Matrix4.diagonal3Values(scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = StudioColors(context);
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final c = context.read<ImageCubit>();
        final source = state.selectedImage;
        if (_sourcePath != source?.path) {
          _sourcePath = source?.path;
          _transform.value = Matrix4.identity();
        }
        final result = state.result;
        final output =
            state.preview ??
            (result?.skipped == false ? result?.thumbnail : null);
        final mode = output == null ? 0 : _view;
        ImageGeometry? outputGeometry;
        if (source != null) {
          try {
            outputGeometry = ImageGeometry.plan(source, state.recipe);
          } catch (_) {
            /* Export validates geometry. */
          }
        }
        return StudioPanel(
          color: colors.canvas,
          minimumContentHeight: 360,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.panel,
                  border: Border(bottom: BorderSide(color: colors.line)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      Container(
                        width: 30,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.field,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: colors.muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              source?.name ?? l.imagePreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (source != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                '${source.format.extension.toUpperCase()}  ·  ${source.width} × ${source.height}  ·  ${imageSizeLabel(l, source.sizeInBytes)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (output != null && constraints.maxWidth > 580)
                        SizedBox(
                          width: 205,
                          child: StudioTabs(
                            labels: [
                              l.original,
                              l.imageStudioCompare,
                              l.imageStudioResult,
                            ],
                            selected: mode,
                            onSelected: (value) =>
                                setState(() => _view = value),
                          ),
                        )
                      else if (output != null)
                        PopupMenuButton<int>(
                          tooltip: l.imageBeforeAfter,
                          onSelected: (value) => setState(() => _view = value),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 0, child: Text(l.original)),
                            PopupMenuItem(
                              value: 1,
                              child: Text(l.imageStudioCompare),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text(l.imageStudioResult),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  [
                                    l.original,
                                    l.imageStudioCompare,
                                    l.imageStudioResult,
                                  ][mode],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colors.muted,
                                  ),
                                ),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 15,
                                  color: colors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      IconButton(
                        tooltip: source == null
                            ? l.imageResourceHint
                            : l.imagePreviewHint,
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l.imageStudioInfo),
                            content: Text(
                              source == null
                                  ? l.imageResourceHint
                                  : l.imagePreviewHint,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l.cancel),
                              ),
                            ],
                          ),
                        ),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: colors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: source == null
                    ? _empty(context, state, c, l)
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: _StudioDots(colors)),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                26,
                                20,
                                26,
                                76,
                              ),
                              child: InteractiveViewer(
                                transformationController: _transform,
                                minScale: .5,
                                maxScale: 8,
                                child: SizedBox.expand(
                                  child: Row(
                                    children: [
                                      if (mode != 2)
                                        Expanded(
                                          child: _CanvasImage(
                                            bytes: source.thumbnail,
                                            width: source.width,
                                            height: source.height,
                                            label: l.original,
                                            colors: colors,
                                            errorLabel: l.imagePreviewError,
                                          ),
                                        ),
                                      if (mode == 1) const SizedBox(width: 20),
                                      if (mode != 0 && output != null)
                                        Expanded(
                                          child: _CanvasImage(
                                            bytes: output,
                                            width: state.preview != null
                                                ? outputGeometry?.width ??
                                                      source.width
                                                : result?.width ?? source.width,
                                            height: state.preview != null
                                                ? outputGeometry?.height ??
                                                      source.height
                                                : result?.height ??
                                                      source.height,
                                            label: state.preview == null
                                                ? l.imageLastExport
                                                : l.imageAfter,
                                            colors: colors,
                                            errorLabel: l.imagePreviewError,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 18,
                            left: 0,
                            right: 0,
                            child: Center(child: _zoomBar(context, l)),
                          ),
                        ],
                      ),
              ),
              _footer(context, state, c, l),
            ],
          ),
        );
      },
    );
  }

  Widget _zoomBar(BuildContext context, AppLocalizations l) {
    final colors = StudioColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.dark ? .12 : .035),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l.imageStudioZoomOut,
            onPressed: () => _zoom(1 / 1.25),
            icon: const Icon(Icons.remove_rounded, size: 16),
          ),
          AnimatedBuilder(
            animation: _transform,
            builder: (_, _) => SizedBox(
              width: 45,
              child: Text(
                l.imageStudioPercent(
                  (_transform.value.getMaxScaleOnAxis() * 100)
                      .round()
                      .toString(),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.imageStudioZoomIn,
            onPressed: () => _zoom(1.25),
            icon: const Icon(Icons.add_rounded, size: 16),
          ),
          Container(
            width: 1,
            height: 16,
            color: colors.line,
            margin: const EdgeInsets.symmetric(horizontal: 6),
          ),
          TextButton(
            onPressed: () => _transform.value = Matrix4.identity(),
            child: Text(l.imageStudioFit, style: const TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) {
    final colors = StudioColors(context);
    final result = state.result;
    final saved = result != null && !result.skipped;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                saved
                    ? Icons.check_circle_outline_rounded
                    : Icons.shield_outlined,
                size: 14,
                color: colors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  saved
                      ? l.imageResultStats(
                          imageSizeLabel(l, result.originalBytes),
                          imageSizeLabel(l, result.outputBytes),
                          result.savings.toStringAsFixed(1),
                        )
                      : l.imageStudioLocal,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: colors.muted),
                ),
              ),
              if (saved) ...[
                IconButton(
                  tooltip: l.imageOpen,
                  onPressed: () => c.openFile(result.path),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                ),
                IconButton(
                  tooltip: l.imageReveal,
                  onPressed: () => c.openFile(result.path, reveal: true),
                  icon: const Icon(Icons.folder_open_rounded, size: 15),
                ),
              ] else if (state.selectedImage != null)
                Text(
                  l.imageStudioReady,
                  style: TextStyle(fontSize: 10, color: colors.faint),
                ),
            ],
          ),
          if (saved && result.notices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Tooltip(
                message: result.notices
                    .map((n) => imageNoticeLabel(l, n))
                    .join('\n'),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: colors.muted,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        imageNoticeLabel(l, result.notices.first),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: colors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(
    BuildContext context,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) {
    final colors = StudioColors(context);
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  height: 128,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: -.15,
                        child: Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            color: colors.field,
                            border: Border.all(color: colors.line),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(10, 2),
                        child: Transform.rotate(
                          angle: .08,
                          child: Container(
                            width: 98,
                            height: 98,
                            decoration: BoxDecoration(
                              color: colors.panel,
                              border: Border.all(color: colors.line),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: colors.dark ? .14 : .045,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.landscape_outlined,
                              size: 36,
                              color: colors.muted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 3,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colors.ink,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.canvas, width: 3),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 17,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l.imageStudioEmptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.8,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.imageStudioEmptyHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.8,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => c.pickImages(l.imageAddFiles),
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(l.imageAddFiles),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final format in ['JPG', 'PNG', 'WEBP', 'TIFF'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.line),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          format,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: .5,
                            color: colors.faint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasImage extends StatelessWidget {
  final Uint8List bytes;
  final int width, height;
  final String label, errorLabel;
  final StudioColors colors;
  const _CanvasImage({
    required this.bytes,
    required this.width,
    required this.height,
    required this.label,
    required this.colors,
    required this.errorLabel,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = math.min(
        constraints.maxWidth / width,
        constraints.maxHeight / height,
      );
      final size = Size(width * scale, height * scale);
      return Center(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: colors.dark ? .28 : .13),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _CheckerPainter())),
                Positioned.fill(
                  child: Image.memory(
                    bytes,
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(child: Text(errorLabel)),
                  ),
                ),
                PositionedDirectional(
                  start: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.panel.withValues(alpha: .94),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _StudioDots extends CustomPainter {
  final StudioColors colors;
  _StudioDots(this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.ink.withValues(alpha: colors.dark ? .055 : .065);
    for (double y = 12; y < size.height; y += 22) {
      for (double x = 12; x < size.width; x += 22) {
        canvas.drawCircle(Offset(x, y), .65, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StudioDots old) => old.colors.dark != colors.dark;
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xfff5f5f5),
    );
    final paint = Paint()..color = const Color(0xffe9e9e9);
    for (double y = 0; y < size.height; y += 12) {
      for (double x = 0; x < size.width; x += 12) {
        if (((x + y) ~/ 12).isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, 12, 12), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}
