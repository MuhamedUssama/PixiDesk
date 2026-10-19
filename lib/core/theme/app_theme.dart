import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_surface_colors.dart';
import 'app_theme_metrics.dart';

/// The single source of typography, component styling, and semantic colors.
abstract final class AppTheme {
  static final ThemeData lightTheme = _createTheme(Brightness.light);
  static final ThemeData darkTheme = _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.dark : AppColors.light;
    final seededColorScheme = ColorScheme.fromSeed(
      seedColor: surfaceColor,
      brightness: brightness,
      surface: surfaceColor,
    );
    final colorScheme = seededColorScheme.copyWith(
      primary: seededColorScheme.onSurface,
      onPrimary: surfaceColor,
      secondary: seededColorScheme.onSurface,
      onSecondary: surfaceColor,
      outline: seededColorScheme.onSurface.withValues(alpha: .2),
      outlineVariant: seededColorScheme.onSurface.withValues(alpha: .08),
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
    final surfaceColors = AppSurfaceColors.fromColorScheme(colorScheme);
    final fontFamily = baseTheme.textTheme.bodyMedium?.fontFamily;
    final fontFamilyFallback =
        baseTheme.textTheme.bodyMedium?.fontFamilyFallback;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeMetrics.controlRadius),
      borderSide: BorderSide(color: surfaceColors.borderColor),
    );
    final textTheme = baseTheme.textTheme.apply(
      bodyColor: surfaceColors.primaryText,
      displayColor: surfaceColors.primaryText,
    );
    return baseTheme.copyWith(
      extensions: [surfaceColors],
      cardTheme: CardThemeData(
        color: surfaceColors.panelBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.cardRadius),
          side: BorderSide(color: surfaceColors.borderColor),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColors.panelBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: surfaceColors.borderColor),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColors.panelBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(fontFamily: fontFamily),
      ),
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: 40,
          height: 1.18,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 28,
          height: 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: -.6,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -.3,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 14, height: 1.6),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -.4,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.5),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 11,
          height: 1.5,
          color: surfaceColors.secondaryText,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: surfaceColors.borderColor,
      dividerTheme: DividerThemeData(
        color: surfaceColors.borderColor,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColors.controlBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: surfaceColors.primaryText.withValues(alpha: .5),
          ),
        ),
        labelStyle: TextStyle(fontSize: 12, color: surfaceColors.secondaryText),
        hintStyle: TextStyle(fontSize: 12, color: surfaceColors.secondaryText),
        floatingLabelStyle: TextStyle(
          fontSize: 12,
          color: surfaceColors.secondaryText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaceColors.primaryText,
          foregroundColor: baseTheme.colorScheme.surface,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.controlRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: surfaceColors.primaryText,
          foregroundColor: baseTheme.colorScheme.surface,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: surfaceColors.primaryText,
          side: BorderSide(color: surfaceColors.borderColor),
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: surfaceColors.secondaryText,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: surfaceColors.secondaryText,
          iconSize: 18,
          minimumSize: const Size(34, 34),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
      sliderTheme: baseTheme.sliderTheme.copyWith(
        activeTrackColor: surfaceColors.primaryText,
        inactiveTrackColor: surfaceColors.borderColor,
        thumbColor: surfaceColors.primaryText,
        overlayColor: surfaceColors.primaryText.withValues(alpha: .06),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (widgetStates) => widgetStates.contains(WidgetState.selected)
              ? surfaceColors.primaryText
              : surfaceColors.borderColor,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (widgetStates) => widgetStates.contains(WidgetState.selected)
              ? baseTheme.colorScheme.surface
              : surfaceColors.secondaryText,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        side: BorderSide(color: surfaceColors.borderColor),
        backgroundColor: surfaceColors.controlBackground,
        selectedColor: surfaceColors.selectedBackground,
        labelStyle: TextStyle(color: surfaceColors.primaryText, fontSize: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        textColor: surfaceColors.primaryText,
        collapsedTextColor: surfaceColors.primaryText,
        iconColor: surfaceColors.secondaryText,
        collapsedIconColor: surfaceColors.secondaryText,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 12),
      ),
      tooltipTheme: baseTheme.tooltipTheme.copyWith(
        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
