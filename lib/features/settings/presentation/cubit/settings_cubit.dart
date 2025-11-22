import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await _repository.getThemeMode();
    final locale = await _repository.getLocale();
    emit(state.copyWith(themeMode: themeMode, locale: locale));
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _repository.saveThemeMode(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> toggleLocale() async {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await _repository.saveLocale(newLocale);
    emit(state.copyWith(locale: newLocale));
  }
}
