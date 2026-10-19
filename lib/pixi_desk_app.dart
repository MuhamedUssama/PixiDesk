import 'dart:async';
import 'core/utils/desktop_image_intake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixi_desk/core/di/injection.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PixiDesk extends StatefulWidget {
  final List<String> initialImagePaths;
  const PixiDesk({super.key, this.initialImagePaths = const []});
  @override
  State<PixiDesk> createState() => _PixiDeskState();
}

class _PixiDeskState extends State<PixiDesk> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _intake = DesktopImageIntake();
  StreamSubscription<List<String>>? _incoming;
  @override
  void initState() {
    super.initState();
    _incoming = _intake.events.listen((paths) {
      _navigatorKey.currentState?.pushNamed(
        AppRouter.imageProcessingRoute,
        arguments: paths,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _intake.initialize(widget.initialImagePaths);
    });
  }

  @override
  void dispose() {
    _incoming?.cancel();
    _intake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.initialRoute,
          );
        },
      ),
    );
  }
}
