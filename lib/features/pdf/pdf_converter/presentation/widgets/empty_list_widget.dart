import 'package:flutter/material.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: isDark
                ? AppColors.darkHeadTextColor
                : AppColors.lightHeadTextColor,
          ),
          Text(
            l10n.dragAndDropImages,
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
