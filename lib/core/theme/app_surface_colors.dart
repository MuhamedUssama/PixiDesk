import 'package:flutter/material.dart';

/// Semantic surfaces shared by all PixiDesk workspaces.
@immutable
class AppSurfaceColors extends ThemeExtension<AppSurfaceColors> {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color disabledText;
  final Color panelBackground;
  final Color canvasBackground;
  final Color controlBackground;
  final Color borderColor;
  final Color selectedBackground;

  const AppSurfaceColors({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.disabledText,
    required this.panelBackground,
    required this.canvasBackground,
    required this.controlBackground,
    required this.borderColor,
    required this.selectedBackground,
  });

  factory AppSurfaceColors.fromColorScheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return AppSurfaceColors(
      isDark: isDark,
      primaryText: colorScheme.onSurface,
      secondaryText: colorScheme.onSurface.withValues(alpha: .65),
      disabledText: colorScheme.onSurface.withValues(alpha: .32),
      panelBackground: Color.alphaBlend(
        Colors.white.withValues(alpha: isDark ? .025 : .78),
        colorScheme.surface,
      ),
      canvasBackground: Color.alphaBlend(
        Colors.black.withValues(alpha: isDark ? .22 : .025),
        colorScheme.surface,
      ),
      controlBackground: colorScheme.onSurface.withValues(alpha: .035),
      borderColor: colorScheme.onSurface.withValues(alpha: .08),
      selectedBackground: colorScheme.onSurface.withValues(alpha: .065),
    );
  }

  static AppSurfaceColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppSurfaceColors>() ??
        AppSurfaceColors.fromColorScheme(theme.colorScheme);
  }

  @override
  AppSurfaceColors copyWith({
    bool? isDark,
    Color? primaryText,
    Color? secondaryText,
    Color? disabledText,
    Color? panelBackground,
    Color? canvasBackground,
    Color? controlBackground,
    Color? borderColor,
    Color? selectedBackground,
  }) => AppSurfaceColors(
    isDark: isDark ?? this.isDark,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    disabledText: disabledText ?? this.disabledText,
    panelBackground: panelBackground ?? this.panelBackground,
    canvasBackground: canvasBackground ?? this.canvasBackground,
    controlBackground: controlBackground ?? this.controlBackground,
    borderColor: borderColor ?? this.borderColor,
    selectedBackground: selectedBackground ?? this.selectedBackground,
  );

  @override
  AppSurfaceColors lerp(AppSurfaceColors? other, double progress) {
    if (other == null) return this;
    return AppSurfaceColors(
      isDark: progress < .5 ? isDark : other.isDark,
      primaryText: Color.lerp(primaryText, other.primaryText, progress)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, progress)!,
      disabledText: Color.lerp(disabledText, other.disabledText, progress)!,
      panelBackground: Color.lerp(
        panelBackground,
        other.panelBackground,
        progress,
      )!,
      canvasBackground: Color.lerp(
        canvasBackground,
        other.canvasBackground,
        progress,
      )!,
      controlBackground: Color.lerp(
        controlBackground,
        other.controlBackground,
        progress,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, progress)!,
      selectedBackground: Color.lerp(
        selectedBackground,
        other.selectedBackground,
        progress,
      )!,
    );
  }
}
