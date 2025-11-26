import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';

class PdfToolItem extends StatelessWidget {
  final VoidCallback onTap;
  final String toolName;
  final String toolDescription;
  final IconData? icon;
  final String? svg;

  const PdfToolItem({
    super.key,
    required this.onTap,
    required this.toolName,
    this.icon,
    required this.toolDescription,
    this.svg,
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
          if (icon != null)
            Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.darkHeadTextColor
                  : AppColors.lightHeadTextColor,
            ),
          if (svg != null) SvgPicture.asset(svg!, width: 24, height: 24),
          Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toolName,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                toolDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
