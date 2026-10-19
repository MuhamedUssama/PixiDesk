import 'package:pixi_desk/core/theme/app_surface_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/image_format.dart';
import '../../domain/entities/image_geometry.dart';
import '../../domain/entities/image_job.dart';
import '../../domain/entities/image_recipe.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import 'image_studio_style.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});
  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = AppSurfaceColors.of(context);
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final c = context.read<ImageCubit>();
        final r = state.recipe;
        void change(ImageRecipe value) => c.updateRecipe(value);
        final anchors = [
          l.imageTopLeft,
          l.imageTopCenter,
          l.imageTopRight,
          l.imageCenterLeft,
          l.imageCenter,
          l.imageCenterRight,
          l.imageBottomLeft,
          l.imageBottomCenter,
          l.imageBottomRight,
        ];
        return StudioPanel(
          minimumContentHeight: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 10, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.imageSettings,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l.imageStudioInspectorHint,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.imageReset,
                      onPressed: state.busy
                          ? null
                          : () => change(const ImageRecipe()),
                      icon: const Icon(Icons.restart_alt_rounded, size: 17),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StudioTabs(
                  labels: [
                    l.imageStudioExport,
                    l.imageStudioEdit,
                    l.imageStudioPresets,
                  ],
                  selected: _tab,
                  onSelected: (value) => setState(() => _tab = value),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    AbsorbPointer(
                      absorbing: state.busy,
                      child: Opacity(
                        opacity: state.busy ? .5 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_tab == 0) ...[
                              _formatPicker(context, r, change, l),
                              const SizedBox(height: 18),
                              _section(l.imageCompression, [
                                if (r.format == ImageFormat.webp)
                                  SwitchListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(l.imageLossless),
                                    value: r.webpLossless,
                                    onChanged: (v) => change(
                                      r.copyWith(
                                        webpLossless: v,
                                        clearTarget: v,
                                      ),
                                    ),
                                  ),
                                if (r.format.supportsQuality &&
                                    !(r.format == ImageFormat.webp &&
                                        r.webpLossless)) ...[
                                  _SettingSlider(
                                    label: l.quality,
                                    value: r.quality.toDouble(),
                                    min: 1,
                                    max: 100,
                                    onChanged: (v) => change(
                                      r.copyWith(
                                        quality: v.round(),
                                        minQuality: math.min(
                                          r.minQuality,
                                          v.round(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _SettingField(
                                    label: l.imageTargetSize,
                                    value: r.targetBytes == null
                                        ? ''
                                        : (r.targetBytes! / 1024)
                                              .round()
                                              .toString(),
                                    onSubmit: (v) {
                                      if (v.isEmpty) {
                                        change(r.copyWith(clearTarget: true));
                                      } else if (int.tryParse(v)
                                          case final int n) {
                                        change(
                                          r.copyWith(targetBytes: n * 1024),
                                        );
                                      }
                                    },
                                  ),
                                  if (r.targetBytes != null)
                                    _SettingSlider(
                                      label: l.imageMinQuality,
                                      value: r.minQuality.toDouble(),
                                      min: 1,
                                      max: r.quality.toDouble(),
                                      onChanged: (v) => change(
                                        r.copyWith(minQuality: v.round()),
                                      ),
                                    ),
                                  Text(
                                    l.imageTargetHint,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ] else
                                  Text(
                                    l.imageLosslessHint,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                if (r.format == ImageFormat.ico)
                                  SwitchListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(l.imageIconPack),
                                    value: r.iconPack,
                                    onChanged: (v) =>
                                        change(r.copyWith(iconPack: v)),
                                  ),
                              ], expanded: true),
                              _section(l.imageMetadata, [
                                DropdownButtonFormField<MetadataPolicy>(
                                  key: ValueKey(r.metadata),
                                  initialValue: r.metadata,
                                  isExpanded: true,
                                  items:
                                      [
                                            l.imageMetadataRemove,
                                            l.imageMetadataPreserve,
                                          ]
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value:
                                                  MetadataPolicy.values[e.key],
                                              child: Text(
                                                e.value,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      change(r.copyWith(metadata: v));
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l.imageMetadataHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<AnimationPolicy>(
                                  key: ValueKey(r.animation),
                                  initialValue: r.animation,
                                  isExpanded: true,
                                  items:
                                      [
                                            l.imageAnimationPreserve,
                                            l.imageAnimationFirst,
                                          ]
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value:
                                                  AnimationPolicy.values[e.key],
                                              child: Text(
                                                e.value,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      change(r.copyWith(animation: v));
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                _SettingField(
                                  label: l.imageBackground,
                                  value: r.backgroundRgb
                                      .toRadixString(16)
                                      .padLeft(6, '0')
                                      .toUpperCase(),
                                  numeric: false,
                                  onSubmit: (v) {
                                    final n = int.tryParse(
                                      v.replaceFirst('#', ''),
                                      radix: 16,
                                    );
                                    if (n != null) {
                                      change(r.copyWith(backgroundRgb: n));
                                    }
                                  },
                                ),
                                Text(
                                  l.imageAlphaHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ]),
                              _section(l.imageNaming, [
                                _SettingField(
                                  label: l.imageNamePattern,
                                  value: state.namingPattern,
                                  numeric: false,
                                  onSubmit: c.setNamingPattern,
                                ),
                                Text(
                                  l.imageNamePatternHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<OutputConflict>(
                                  key: ValueKey(state.conflict),
                                  initialValue: state.conflict,
                                  isExpanded: true,
                                  items:
                                      [
                                            l.imageConflictRename,
                                            l.imageConflictSkip,
                                            l.imageConflictReplace,
                                          ]
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value:
                                                  OutputConflict.values[e.key],
                                              child: Text(
                                                e.value,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null) c.setConflict(v);
                                  },
                                ),
                                if (state.conflict == OutputConflict.replace)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(l.imageReplaceHint),
                                  ),
                                TextButton.icon(
                                  onPressed: () =>
                                      c.chooseOutputFolder(l.imageOutputFolder),
                                  icon: const Icon(Icons.folder_open),
                                  label: Text(l.imageOutputFolder),
                                ),
                                if (state.outputFolder != null)
                                  SelectableText(
                                    state.outputFolder!,
                                    key: const PageStorageKey(
                                      'image-output-folder',
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ]),
                            ],
                            if (_tab == 1) ...[
                              _section(l.imageResize, [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SettingField(
                                        label: l.imageWidth,
                                        value: r.width?.toString() ?? '',
                                        hint: l.imageKeepOriginal,
                                        onSubmit: (v) {
                                          if (v.isEmpty) {
                                            change(
                                              r.copyWith(clearWidth: true),
                                            );
                                          } else if (int.tryParse(v)
                                              case final int n) {
                                            change(r.copyWith(width: n));
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _SettingField(
                                        label: l.imageHeight,
                                        value: r.height?.toString() ?? '',
                                        hint: l.imageKeepOriginal,
                                        onSubmit: (v) {
                                          if (v.isEmpty) {
                                            change(
                                              r.copyWith(clearHeight: true),
                                            );
                                          } else if (int.tryParse(v)
                                              case final int n) {
                                            change(r.copyWith(height: n));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<ResizeMode>(
                                  isExpanded: true,
                                  key: ValueKey(r.resizeMode),
                                  initialValue: r.resizeMode,
                                  items:
                                      [
                                            l.imageResizeFit,
                                            l.imageResizeFill,
                                            l.imageResizeStretch,
                                          ]
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: ResizeMode.values[e.key],
                                              child: Text(
                                                e.value,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      change(r.copyWith(resizeMode: v));
                                    }
                                  },
                                ),
                                SwitchListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l.imageAllowUpscale),
                                  value: r.allowUpscale,
                                  onChanged: (v) =>
                                      change(r.copyWith(allowUpscale: v)),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      tooltip: l.imageRotate,
                                      icon: const Icon(Icons.rotate_right),
                                      onPressed: () => change(
                                        r.copyWith(
                                          quarterTurns:
                                              (r.quarterTurns + 1) % 4,
                                        ),
                                      ),
                                    ),
                                    FilterChip(
                                      label: Text(l.imageFlipHorizontal),
                                      selected: r.flipHorizontal,
                                      onSelected: (v) =>
                                          change(r.copyWith(flipHorizontal: v)),
                                    ),
                                    FilterChip(
                                      label: Text(l.imageFlipVertical),
                                      selected: r.flipVertical,
                                      onSelected: (v) =>
                                          change(r.copyWith(flipVertical: v)),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        final source = state.selectedImage;
                                        if (source == null) return;
                                        final ratio =
                                            source.width / source.height;
                                        final cw = ratio > 1 ? 1 / ratio : 1.0,
                                            ch = ratio < 1 ? ratio : 1.0;
                                        change(
                                          r.copyWith(
                                            cropLeft: (1 - cw) / 2,
                                            cropTop: (1 - ch) / 2,
                                            cropWidth: cw,
                                            cropHeight: ch,
                                          ),
                                        );
                                      },
                                      child: Text(l.imageSquareCrop),
                                    ),
                                    TextButton(
                                      onPressed: () => change(
                                        r.copyWith(
                                          cropLeft: 0,
                                          cropTop: 0,
                                          cropWidth: 1,
                                          cropHeight: 1,
                                        ),
                                      ),
                                      child: Text(l.imageResetCrop),
                                    ),
                                  ],
                                ),
                                _SettingField(
                                  label: l.imageCropLeft,
                                  value: (r.cropLeft * 100).toStringAsFixed(1),
                                  onSubmit: (v) {
                                    final n = double.tryParse(v);
                                    if (n != null) {
                                      change(
                                        r.copyWith(
                                          cropLeft: n / 100,
                                          cropWidth: math.min(
                                            r.cropWidth,
                                            1 - n / 100,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                _SettingField(
                                  label: l.imageCropTop,
                                  value: (r.cropTop * 100).toStringAsFixed(1),
                                  onSubmit: (v) {
                                    final n = double.tryParse(v);
                                    if (n != null) {
                                      change(
                                        r.copyWith(
                                          cropTop: n / 100,
                                          cropHeight: math.min(
                                            r.cropHeight,
                                            1 - n / 100,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                _SettingField(
                                  label: l.imageCropWidth,
                                  value: (r.cropWidth * 100).toStringAsFixed(1),
                                  onSubmit: (v) {
                                    final n = double.tryParse(v);
                                    if (n != null) {
                                      change(r.copyWith(cropWidth: n / 100));
                                    }
                                  },
                                ),
                                _SettingField(
                                  label: l.imageCropHeight,
                                  value: (r.cropHeight * 100).toStringAsFixed(
                                    1,
                                  ),
                                  onSubmit: (v) {
                                    final n = double.tryParse(v);
                                    if (n != null) {
                                      change(r.copyWith(cropHeight: n / 100));
                                    }
                                  },
                                ),
                              ]),
                              _section(l.imageAdjustments, [
                                _SettingSlider(
                                  label: l.imageBrightness,
                                  value: r.brightness,
                                  min: 0,
                                  max: 2,
                                  onChanged: (v) =>
                                      change(r.copyWith(brightness: v)),
                                ),
                                _SettingSlider(
                                  label: l.imageContrast,
                                  value: r.contrast,
                                  min: 0,
                                  max: 2,
                                  onChanged: (v) =>
                                      change(r.copyWith(contrast: v)),
                                ),
                                _SettingSlider(
                                  label: l.imageSaturation,
                                  value: r.saturation,
                                  min: 0,
                                  max: 2,
                                  onChanged: (v) =>
                                      change(r.copyWith(saturation: v)),
                                ),
                                SwitchListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l.imageGrayscale),
                                  value: r.grayscale,
                                  onChanged: (v) =>
                                      change(r.copyWith(grayscale: v)),
                                ),
                              ]),
                              _section(l.imageWatermark, [
                                _SettingField(
                                  label: l.imageWatermarkText,
                                  value: r.watermarkText,
                                  numeric: false,
                                  onSubmit: (v) =>
                                      change(r.copyWith(watermarkText: v)),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.branding_watermark),
                                  label: Text(l.imageWatermarkLogo),
                                  onPressed: () =>
                                      c.chooseWatermark(l.imageWatermarkLogo),
                                ),
                                if (r.watermarkPath != null)
                                  TextButton(
                                    onPressed: () => change(
                                      r.copyWith(clearWatermark: true),
                                    ),
                                    child: Text(l.imageWatermarkRemove),
                                  ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<WatermarkAnchor>(
                                  isExpanded: true,
                                  key: ValueKey(r.watermarkAnchor),
                                  initialValue: r.watermarkAnchor,
                                  items: anchors
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: WatermarkAnchor.values[e.key],
                                          child: Text(
                                            e.value,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      change(r.copyWith(watermarkAnchor: v));
                                    }
                                  },
                                ),
                                _SettingSlider(
                                  label: l.imageOpacity,
                                  value: r.watermarkOpacity,
                                  min: 0,
                                  max: 1,
                                  onChanged: (v) =>
                                      change(r.copyWith(watermarkOpacity: v)),
                                ),
                                _SettingSlider(
                                  label: l.imageWatermarkScale,
                                  value: r.watermarkScale,
                                  min: .05,
                                  max: 1,
                                  onChanged: (v) =>
                                      change(r.copyWith(watermarkScale: v)),
                                ),
                              ]),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: l.imageUndo,
                                    onPressed: state.canUndo ? c.undo : null,
                                    icon: const Icon(Icons.undo_rounded),
                                  ),
                                  IconButton(
                                    tooltip: l.imageRedo,
                                    onPressed: state.canRedo ? c.redo : null,
                                    icon: const Icon(Icons.redo_rounded),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: TextButton(
                                        onPressed: () =>
                                            change(const ImageRecipe()),
                                        child: Text(
                                          l.imageReset,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_tab == 2) ...[
                              _section(l.imagePresets, [
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    ActionChip(
                                      label: Text(l.imagePresetSharing),
                                      onPressed: () => change(
                                        const ImageRecipe(
                                          format: ImageFormat.jpg,
                                          quality: 82,
                                        ),
                                      ),
                                    ),
                                    ActionChip(
                                      label: Text(l.imagePresetTransparent),
                                      onPressed: () =>
                                          change(const ImageRecipe()),
                                    ),
                                    ActionChip(
                                      label: Text(l.imagePresetStore),
                                      onPressed: () => change(
                                        const ImageRecipe(
                                          format: ImageFormat.jpg,
                                          width: 1600,
                                          height: 1600,
                                          quality: 85,
                                        ),
                                      ),
                                    ),
                                    ActionChip(
                                      label: Text(l.imagePresetIcon),
                                      onPressed: () => change(
                                        const ImageRecipe(
                                          format: ImageFormat.ico,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (final preset in state.presets)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      preset.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => change(preset.recipe),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'rename',
                                          child: Text(l.imageRenamePreset),
                                        ),
                                        PopupMenuItem(
                                          value: 'duplicate',
                                          child: Text(l.imageDuplicatePreset),
                                        ),
                                        PopupMenuItem(
                                          value: 'export',
                                          child: Text(l.imageExportPreset),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(l.imageDeletePreset),
                                        ),
                                      ],
                                      onSelected: (v) {
                                        if (v == 'export') {
                                          c.exportPreset(
                                            l.imageExportPreset,
                                            preset,
                                          );
                                        } else if (v == 'delete') {
                                          c.deletePreset(preset.id);
                                        } else {
                                          _savePreset(
                                            context,
                                            c,
                                            l,
                                            preset: preset,
                                            rename: v == 'rename',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: () => _savePreset(context, c, l),
                                  icon: const Icon(Icons.bookmark_add_outlined),
                                  label: Text(l.imageSavePreset),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      c.importPreset(l.imageImportPreset),
                                  icon: const Icon(Icons.file_open_outlined),
                                  label: Text(l.imageImportPreset),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _exportFooter(context, state, c, l),
            ],
          ),
        );
      },
    );
  }

  Widget _formatPicker(
    BuildContext context,
    ImageRecipe r,
    ValueChanged<ImageRecipe> change,
    AppLocalizations l,
  ) {
    final colors = AppSurfaceColors.of(context);
    void select(ImageFormat f) => change(
      r.copyWith(
        format: f,
        clearTarget:
            !f.supportsQuality || (f == ImageFormat.webp && r.webpLossless),
      ),
    );
    const common = [ImageFormat.png, ImageFormat.jpg, ImageFormat.webp];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.outputFormat,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.secondaryText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < common.length; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              Expanded(
                child: Semantics(
                  selected: r.format.canonical == common[i],
                  button: true,
                  child: Material(
                    color: r.format.canonical == common[i]
                        ? colors.primaryText
                        : colors.controlBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: r.format.canonical == common[i]
                            ? colors.primaryText
                            : colors.borderColor,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => select(common[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          common[i].extension.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: r.format.canonical == common[i]
                                ? Theme.of(context).colorScheme.surface
                                : colors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: PopupMenuButton<ImageFormat>(
            tooltip: l.imageStudioMoreFormats,
            onSelected: select,
            itemBuilder: (_) => ImageFormat.outputFormats
                .where((f) => !common.contains(f))
                .map(
                  (f) => PopupMenuItem(
                    value: f,
                    child: Text(f.extension.toUpperCase()),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    common.contains(r.format.canonical)
                        ? l.imageStudioMoreFormats
                        : r.format.extension.toUpperCase(),
                    style: TextStyle(fontSize: 11, color: colors.secondaryText),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 14,
                    color: colors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exportFooter(
    BuildContext context,
    ImageState state,
    ImageCubit c,
    AppLocalizations l,
  ) {
    final colors = AppSurfaceColors.of(context);
    final source = state.selectedImage;
    ImageGeometry? geometry;
    if (source != null) {
      try {
        geometry = ImageGeometry.plan(source, state.recipe);
      } catch (_) {
        /* Invalid geometry is reported by the processing use case. */
      }
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colors.panelBackground,
        border: Border(top: BorderSide(color: colors.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (geometry != null) ...[
            Row(
              children: [
                Text(
                  state.recipe.format.extension.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${geometry.width} × ${geometry.height}',
                  style: TextStyle(fontSize: 10, color: colors.disabledText),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 12,
                  color: colors.disabledText,
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: state.busy || source == null ? null : c.preview,
                  child: Tooltip(
                    message: l.imageStudioPreviewAction,
                    child: const Icon(Icons.preview_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.busy || source == null
                      ? null
                      : () => c.exportImage(l.imageExportTitle),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: Text(l.imageStudioSingleExport),
                ),
              ),
              PopupMenuButton<String>(
                enabled: !state.busy && source != null,
                tooltip: l.imageStudioMore,
                icon: const Icon(Icons.more_vert_rounded, size: 17),
                onSelected: (_) =>
                    c.exportImage(l.imageExportTitle, compress: true),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'compress', child: Text(l.compress)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<Widget> children, {
    bool expanded = false,
  }) {
    final l = AppLocalizations.of(context)!;
    final colors = AppSurfaceColors.of(context);
    final icons = {
      l.imageCompression: Icons.tune_rounded,
      l.imageResize: Icons.crop_rounded,
      l.imageAdjustments: Icons.tonality_rounded,
      l.imageMetadata: Icons.info_outline_rounded,
      l.imageWatermark: Icons.branding_watermark_outlined,
      l.imageNaming: Icons.drive_file_rename_outline_rounded,
      l.imagePresets: Icons.bookmarks_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.controlBackground,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: ExpansionTile(
            key: PageStorageKey(title),
            initiallyExpanded:
                expanded || title == l.imageResize || title == l.imagePresets,
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Row(
              children: [
                Icon(icons[title], size: 15, color: colors.secondaryText),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreset(
    BuildContext context,
    ImageCubit c,
    AppLocalizations l, {
    ImagePreset? preset,
    bool rename = false,
  }) async {
    final controller = TextEditingController(text: preset?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.imageSavePreset),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(labelText: l.imagePresetName),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.pop(ctx, v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    // Dialog route animations may still reference its text controller.
    if (name != null && !c.isClosed) {
      if (rename && preset != null) {
        await c.renamePreset(preset.id, name);
      } else {
        await c.savePreset(name, recipe: preset?.recipe);
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.dispose();
  }
}

class _SettingField extends StatefulWidget {
  final String label, value;
  final String? hint;
  final bool numeric;
  final ValueChanged<String> onSubmit;
  const _SettingField({
    required this.label,
    required this.value,
    required this.onSubmit,
    this.hint,
    this.numeric = true,
  });
  @override
  State<_SettingField> createState() => _SettingFieldState();
}

class _SettingFieldState extends State<_SettingField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  @override
  void didUpdateWidget(_SettingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focus.hasFocus) {
      _controller.text = widget.value;
    }
  }

  void _commit() {
    if (_controller.text != widget.value) {
      widget.onSubmit(_controller.text.trim());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppSurfaceColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(fontSize: 11, color: colors.secondaryText),
          ),
          const SizedBox(height: 7),
          Semantics(
            label: widget.label,
            textField: true,
            child: TextField(
              // Keep text scroll offsets separate from the ancestor tile's
              // boolean expansion state in the route's PageStorage bucket.
              key: PageStorageKey('image-setting:${widget.label}'),
              controller: _controller,
              focusNode: _focus,
              style: TextStyle(fontSize: 12, color: colors.primaryText),
              keyboardType: widget.numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(hintText: widget.hint),
              onSubmitted: (_) => _commit(),
              onTapOutside: (_) {
                _focus.unfocus();
                _commit();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingSlider extends StatefulWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  @override
  State<_SettingSlider> createState() => _SettingSliderState();
}

class _SettingSliderState extends State<_SettingSlider> {
  double? _drag;
  @override
  Widget build(BuildContext context) {
    final value = (_drag ?? widget.value).clamp(widget.min, widget.max);
    final colors = AppSurfaceColors.of(context);
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.label, style: const TextStyle(fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.panelBackground,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  l.imageStudioPercent(
                    (widget.max > 2 ? value : value * 100).round().toString(),
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: widget.min,
            max: widget.max == widget.min ? widget.min + .001 : widget.max,
            onChanged: (v) => setState(() => _drag = v),
            onChangeEnd: (v) {
              setState(() => _drag = null);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
