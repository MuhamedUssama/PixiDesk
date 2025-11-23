import 'package:flutter/material.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';

class PdfToolItem extends StatelessWidget {
  final VoidCallback onTap;
  final String toolName;
  final IconData icon;
  const PdfToolItem({
    super.key,
    required this.onTap,
    required this.toolName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return TextButton(
      onPressed: onTap,
      child: Row(
        spacing: 16,
        children: [
          Icon(
            icon,
            size: 24,
            color: isDark
                ? AppColors.darkHeadTextColor
                : AppColors.lightHeadTextColor,
          ),
          Text(
            toolName,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
