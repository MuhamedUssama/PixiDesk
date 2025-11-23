import 'package:flutter/material.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/features/landing/presentation/widgets/feature_card_widget.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class MainLandingPage extends StatelessWidget {
  const MainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
              child: Column(
                children: [
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appSubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                FeatureCardWidget(
                  icon: Icons.image_outlined,
                  title: l10n.imageProcessingTitle,
                  subtitle: l10n.imageProcessingSubtitle,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.imageProcessingRoute,
                    );
                  },
                ),
                FeatureCardWidget(
                  icon: Icons.picture_as_pdf_outlined,
                  title: l10n.pdfTools,
                  subtitle: l10n.pdfToolsSubtitle,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.pdfConverterRoute);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
