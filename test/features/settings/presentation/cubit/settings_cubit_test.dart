import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/settings/domain/repositories/settings_repository.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SettingsCubit cubit;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
    // Default stubs
    when(
      () => mockRepository.getThemeMode(),
    ).thenAnswer((_) async => ThemeMode.system);
    when(
      () => mockRepository.getLocale(),
    ).thenAnswer((_) async => const Locale('en'));
    when(() => mockRepository.saveThemeMode(any())).thenAnswer((_) async {});
    when(() => mockRepository.saveLocale(any())).thenAnswer((_) async {});

    cubit = SettingsCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit', () {
    test('initial state is correct', () {
      expect(
        cubit.state,
        const SettingsState(themeMode: ThemeMode.system, locale: Locale('en')),
      );
    });

    blocTest<SettingsCubit, SettingsState>(
      'emits [SettingsState] with new ThemeMode when toggleTheme is called',
      build: () => cubit,
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        const SettingsState(themeMode: ThemeMode.dark, locale: Locale('en')),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [SettingsState] with new Locale when toggleLocale is called',
      build: () => cubit,
      act: (cubit) => cubit.toggleLocale(),
      expect: () => [
        const SettingsState(themeMode: ThemeMode.system, locale: Locale('ar')),
      ],
    );
  });
}
