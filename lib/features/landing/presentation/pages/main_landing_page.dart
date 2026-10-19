import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_surface_colors.dart';
import '../../../../core/widgets/app_catalog_page.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../widgets/feature_card_widget.dart';

class MainLandingPage extends StatelessWidget {
  const MainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final surfaceColors = AppSurfaceColors.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return AppCatalogPage(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: surfaceColors.primaryText,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.auto_awesome_mosaic_rounded,
                size: 17,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                localizations.appTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: localizations.changeLanguage,
            icon: const Icon(Icons.language_rounded),
            onPressed: () => context.read<SettingsCubit>().toggleLocale(),
          ),
          IconButton(
            tooltip: isDarkTheme
                ? localizations.switchToLightTheme
                : localizations.switchToDarkTheme,
            icon: Icon(
              isDarkTheme
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<SettingsCubit>().toggleTheme(
              currentBrightness: Theme.of(context).brightness,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      eyebrow: localizations.homeEyebrow,
      title: localizations.homeHeadline,
      description: localizations.homeDescription,
      sectionTitle: localizations.homeWorkspaces,
      sectionCaption: localizations.desktopWorkspaceCaption,
      maxColumns: 2,
      toolCards: [
        FeatureCardWidget(
          icon: Icons.photo_library_outlined,
          title: localizations.imageStudioTitle,
          description: localizations.homeImageDescription,
          actionLabel: localizations.openImageStudio,
          capabilityLabels: [
            localizations.catalogEdit,
            localizations.catalogConvert,
            localizations.catalogCompress,
          ],
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.imageProcessingRoute),
        ),
        FeatureCardWidget(
          icon: Icons.description_outlined,
          title: localizations.pdfTools,
          description: localizations.homePdfDescription,
          actionLabel: localizations.explorePdfTools,
          capabilityLabels: [
            localizations.catalogCreate,
            localizations.catalogCompress,
            localizations.catalogExtract,
          ],
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.pdfToolsRoute),
        ),
      ],
    );
  }
}
