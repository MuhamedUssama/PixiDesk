import 'package:flutter/material.dart';
import '../theme/app_surface_colors.dart';
import '../theme/app_theme_metrics.dart';

/// A keyboard-accessible entry point shared by the home and PDF catalogs.
class AppToolCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final List<String> capabilityLabels;
  final VoidCallback onPressed;

  const AppToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
    this.capabilityLabels = const [],
  });

  @override
  State<AppToolCard> createState() => _AppToolCardState();
}

class _AppToolCardState extends State<AppToolCard> {
  bool _isHovered = false;
  bool _hasKeyboardFocus = false;

  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isHighlighted = _isHovered || _hasKeyboardFocus;
    final borderRadius = BorderRadius.circular(AppThemeMetrics.cardRadius);

    return Semantics(
      button: true,
      child: AnimatedContainer(
        duration: AppThemeMetrics.interactionDuration,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: surfaceColors.panelBackground,
          borderRadius: borderRadius,
          border: Border.all(
            color: isHighlighted
                ? surfaceColors.primaryText.withValues(alpha: .3)
                : surfaceColors.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isHighlighted ? (surfaceColors.isDark ? .16 : .045) : 0,
              ),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: widget.onPressed,
            onHover: (isHovered) => setState(() => _isHovered = isHovered),
            onFocusChange: (hasFocus) =>
                setState(() => _hasKeyboardFocus = hasFocus),
            hoverColor: surfaceColors.selectedBackground.withValues(
              alpha: .025,
            ),
            focusColor: surfaceColors.selectedBackground,
            child: Padding(
              padding: const EdgeInsets.all(AppThemeMetrics.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: surfaceColors.controlBackground,
                                border: Border.all(
                                  color: surfaceColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 23,
                                color: surfaceColors.primaryText,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ExcludeSemantics(
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                              color: isHighlighted
                                  ? surfaceColors.primaryText
                                  : surfaceColors.disabledText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(widget.title, style: textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: textTheme.bodyLarge?.copyWith(
                          color: surfaceColors.secondaryText,
                        ),
                      ),
                      if (widget.capabilityLabels.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final capabilityLabel
                                in widget.capabilityLabels)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceColors.controlBackground,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  capabilityLabel,
                                  style: textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Text(
                          widget.actionLabel,
                          style: textTheme.labelLarge?.copyWith(
                            color: surfaceColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
