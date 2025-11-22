import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<void> saveThemeMode(ThemeMode mode);
  Future<ThemeMode> getThemeMode();
  Future<void> saveLocale(Locale locale);
  Future<Locale> getLocale();
}
