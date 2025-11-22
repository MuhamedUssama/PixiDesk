import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixi_desk/core/di/injection.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
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
