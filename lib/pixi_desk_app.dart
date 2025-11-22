import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixi_desk/core/di/injection.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/image_processing/presentation/pages/home_page.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PixiDesk extends StatelessWidget {
  const PixiDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Pixi Desk',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: ThemeData(
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
              ),
            ),
            darkTheme: ThemeData(
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
              ),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            locale: state.locale,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
