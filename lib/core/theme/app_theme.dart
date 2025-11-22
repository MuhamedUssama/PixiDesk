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
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
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
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.light,
      foregroundColor: AppColors.lightHeadTextColor,
      surfaceTintColor: Colors.transparent,
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
  );
}
