import 'package:flutter/material.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class EmptyCompressPdfStateWidget extends StatelessWidget {
  const EmptyCompressPdfStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: isDark
                ? AppColors.darkHeadTextColor
                : AppColors.lightHeadTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dragDropPdf,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isDark
                  ? AppColors.darkHeadTextColor
                  : AppColors.lightHeadTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
