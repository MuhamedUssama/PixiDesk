import 'package:flutter/material.dart';
import '../../../../core/theme/app_surface_colors.dart';
import '../../../../core/theme/app_theme_metrics.dart';

class StudioPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double minimumContentHeight;
  const StudioPanel({
    super.key,
    required this.child,
    this.color,
    this.minimumContentHeight = 0,
  });
  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? surfaceColors.panelBackground,
        border: Border.all(color: surfaceColors.borderColor),
        borderRadius: BorderRadius.circular(AppThemeMetrics.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minimumHeight =
              minimumContentHeight *
              (MediaQuery.textScalerOf(context).scale(1) > 1.4 ? 1.5 : 1);
          if (constraints.maxHeight.isFinite &&
              constraints.maxHeight < minimumHeight) {
            return SingleChildScrollView(
              child: SizedBox(height: minimumHeight, child: child),
            );
          }
          return child;
        },
      ),
    );
  }
}

class StudioTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  const StudioTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceColors.controlBackground,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Expanded(
            child: Semantics(
              selected: selected == index,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected == index
                        ? surfaceColors.panelBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == index
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: surfaceColors.isDark ? .1 : .045,
                              ),
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected == index
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: selected == index
                          ? surfaceColors.primaryText
                          : surfaceColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
