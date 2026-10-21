import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/core/widgets/app_tool_card.dart';
import 'package:pixi_desk/features/landing/presentation/pages/main_landing_page.dart';
import 'package:pixi_desk/features/pdf/pdf_tools_page.dart';
import 'package:pixi_desk/features/settings/domain/repositories/settings_repository.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class _MemorySettingsRepository implements SettingsRepository {
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('en');
  @override
  Future<ThemeMode> getThemeMode() async => themeMode;
  @override
  Future<Locale> getLocale() async => locale;
  @override
  Future<void> saveThemeMode(ThemeMode value) async => themeMode = value;
  @override
  Future<void> saveLocale(Locale value) async => locale = value;
}

Widget _testApplication({
  required Widget home,
  String locale = 'en',
  Brightness brightness = Brightness.light,
  double textScale = 1,
  RouteFactory? onGenerateRoute,
}) => MaterialApp(
  theme: brightness == Brightness.dark
      ? AppTheme.darkTheme
      : AppTheme.lightTheme,
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  onGenerateRoute: onGenerateRoute,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

void _setWindowSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final locale in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      for (final windowSize in [
        const Size(1440, 900),
        const Size(900, 700),
        const Size(360, 500),
      ]) {
        testWidgets(
          '$locale $brightness catalogs adapt to $windowSize and enlarged text',
          (tester) async {
            _setWindowSize(tester, windowSize);
            for (final page in [
              const MainLandingPage(),
              const PdfToolsPage(),
            ]) {
              await tester.pumpWidget(
                _testApplication(
                  home: page,
                  locale: locale,
                  brightness: brightness,
                  textScale: windowSize.width < 400 ? 1.8 : 1,
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              final cardFinder = find.byType(AppToolCard);
              expect(
                cardFinder,
                findsNWidgets(page is MainLandingPage ? 2 : 4),
              );
              for (
                var cardIndex = 0;
                cardIndex < cardFinder.evaluate().length;
                cardIndex++
              ) {
                await tester.ensureVisible(cardFinder.at(cardIndex));
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              // Reset scroll and inherited layout state between catalogs.
              await tester.pumpWidget(const SizedBox());
            }
          },
        );
      }
    }
  }

  testWidgets(
    'catalog cards open the correct routes and preserve back navigation',
    (tester) async {
      _setWindowSize(tester, const Size(1440, 900));
      for (final page in [const MainLandingPage(), const PdfToolsPage()]) {
        final expectedRoutes = page is MainLandingPage
            ? [AppRouter.imageProcessingRoute, AppRouter.pdfToolsRoute]
            : [
                AppRouter.pdfConverterRoute,
                AppRouter.pdfCompressionRoute,
                AppRouter.pdfToImageRoute,
                AppRouter.pdfMergeRoute,
              ];
        await tester.pumpWidget(
          _testApplication(
            home: page,
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (context) => Scaffold(
                appBar: AppBar(),
                body: Text('Destination ${settings.name}'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (
          var cardIndex = 0;
          cardIndex < expectedRoutes.length;
          cardIndex++
        ) {
          final cardFinder = find.byType(AppToolCard).at(cardIndex);
          await tester.ensureVisible(cardFinder);
          await tester.tap(cardFinder);
          await tester.pumpAndSettle();
          expect(
            find.text('Destination ${expectedRoutes[cardIndex]}'),
            findsOneWidget,
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(
            find.byType(AppToolCard),
            findsNWidgets(expectedRoutes.length),
          );
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets('tool card can be reached and activated with the keyboard', (
    tester,
  ) async {
    var activationCount = 0;
    await tester.pumpWidget(
      _testApplication(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AppToolCard(
              icon: Icons.description_outlined,
              title: 'Documents',
              description: 'Work with your documents.',
              actionLabel: 'Open workspace',
              onPressed: () => activationCount++,
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(activationCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home toggles language and the visible system dark theme', (
    tester,
  ) async {
    _setWindowSize(tester, const Size(1024, 768));
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final settingsCubit = SettingsCubit(_MemorySettingsRepository());
    addTearDown(settingsCubit.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) => MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainLandingPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(MainLandingPage))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byTooltip('Switch to light theme'));
    await tester.pumpAndSettle();
    expect(settingsCubit.state.themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.byType(MainLandingPage))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byTooltip('Change language'));
    await tester.pumpAndSettle();
    expect(settingsCubit.state.locale, const Locale('ar'));
    expect(find.text('بيكسي ديسك'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(MainLandingPage))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
