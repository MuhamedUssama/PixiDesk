import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_keys.dart';
import '../../domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeString = _prefs.getString(AppKeys.themeMode);
    if (themeString == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<Locale> getLocale() async {
    final localeString = _prefs.getString(AppKeys.locale);
    if (localeString == null) return const Locale('en');
    return Locale(localeString);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(AppKeys.themeMode, mode.toString());
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(AppKeys.locale, locale.languageCode);
  }
}
