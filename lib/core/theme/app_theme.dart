import 'package:flutter/material.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.dark,
    cardColor: AppColors.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dark,
      brightness: Brightness.dark,
      surface: AppColors.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.dark,
    dividerTheme: const DividerThemeData(color: AppColors.darkHeadTextColor),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.darkHeadTextColor,
      cursorColor: AppColors.darkHeadTextColor,
      selectionHandleColor: AppColors.darkHeadTextColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkHeadTextColor,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.dark,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.darkHeadTextColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkHeadTextColor),
      headlineSmall: TextStyle(
        color: AppColors.darkHeadTextColor,
        fontSize: 18,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(AppColors.white),
      checkColor: WidgetStateProperty.all(AppColors.dark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.dark),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 16,
        ),
        labelStyle: TextStyle(color: AppColors.darkHeadTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      labelStyle: TextStyle(color: AppColors.darkHeadTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.darkHeadTextColor, width: 1),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.light,
    cardColor: AppColors.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.light,
      brightness: Brightness.light,
      surface: AppColors.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.light,
    dividerTheme: const DividerThemeData(color: AppColors.lightHeadTextColor),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.lightHeadTextColor,
      cursorColor: AppColors.lightHeadTextColor,
      selectionHandleColor: AppColors.lightHeadTextColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.light,
      foregroundColor: AppColors.lightHeadTextColor,
      surfaceTintColor: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightHeadTextColor,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.light,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightHeadTextColor),
      headlineSmall: TextStyle(
        color: AppColors.lightHeadTextColor,
        fontSize: 18,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(AppColors.dark),
      checkColor: WidgetStateProperty.all(AppColors.light),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.light),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 16,
        ),
        labelStyle: TextStyle(color: AppColors.lightHeadTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      labelStyle: TextStyle(color: AppColors.lightHeadTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightHeadTextColor, width: 1),
      ),
    ),
  );
}
