import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'features/image_processing/presentation/pages/home_page.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixi Desk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.dark,
          brightness: Brightness.dark,
          surface: AppColors.dark,
          // background is deprecated in newer Flutter versions, use surface or colorScheme.background if needed
          // but surface is enough usually.
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.dark,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      home: const HomePage(),
    );
  }
}
