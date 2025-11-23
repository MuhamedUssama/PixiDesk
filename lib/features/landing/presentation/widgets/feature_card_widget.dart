import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeatureCardWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<FeatureCardWidget> createState() => _FeatureCardWidgetState();
}

class _FeatureCardWidgetState extends State<FeatureCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.dark : AppColors.light;
    final textColor = isDark
        ? AppColors.darkHeadTextColor
        : AppColors.lightHeadTextColor;
    final subTextColor = isDark
        ? AppColors.darkHeadTextColor.withValues(alpha: 0.7)
        : AppColors.lightTextColor;

    final scale = _isHovered ? 1.02 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scaleByDouble(scale, scale, scale, 1.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.2 : 0.05),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 2,
            ),
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: _isHovered ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 56,
                  color: isDark
                      ? AppColors.darkHeadTextColor
                      : AppColors.lightHeadTextColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: subTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
