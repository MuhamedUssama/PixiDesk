import 'package:flutter/material.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../l10n/localization/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  final AppLocalizations l10n;
  const EmptyStateWidget({super.key, required this.l10n});
  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColors.controlBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.description_outlined,
            size: 48,
            color: surfaceColors.secondaryText,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.dragDropPdf,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
