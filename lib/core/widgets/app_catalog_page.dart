import 'package:flutter/material.dart';
import '../theme/app_surface_colors.dart';
import '../theme/app_theme_metrics.dart';

/// Responsive catalog shell. Cards grow with copy and text scale, rather than
/// being constrained by a fixed grid aspect ratio or a fixed-height container.
class AppCatalogPage extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final String eyebrow;
  final String title;
  final String description;
  final String sectionTitle;
  final String sectionCaption;
  final List<Widget> toolCards;
  final int maxColumns;

  const AppCatalogPage({
    super.key,
    required this.appBar,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.sectionTitle,
    required this.sectionCaption,
    required this.toolCards,
    this.maxColumns = 3,
  }) : assert(maxColumns > 0);

  @override
  Widget build(BuildContext context) {
    final surfaceColors = AppSurfaceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, pageConstraints) {
            final isCompact = pageConstraints.maxWidth < 700;
            final pagePadding = isCompact
                ? AppThemeMetrics.compactPagePadding
                : AppThemeMetrics.pagePadding;
            return SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding,
                    isCompact ? 32 : 56,
                    pagePadding,
                    40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppThemeMetrics.pageMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 1,
                              color: surfaceColors.secondaryText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                eyebrow,
                                style: textTheme.labelMedium?.copyWith(
                                  color: surfaceColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          style: isCompact
                              ? textTheme.headlineMedium
                              : textTheme.displaySmall,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 580),
                            child: Text(
                              description,
                              style: textTheme.bodyLarge?.copyWith(
                                color: surfaceColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Divider(height: 1),
                        const SizedBox(height: AppThemeMetrics.sectionGap),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Text(sectionTitle, style: textTheme.titleMedium),
                            Text(sectionCaption, style: textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _CatalogToolGrid(
                          toolCards: toolCards,
                          maxColumns: maxColumns,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogToolGrid extends StatelessWidget {
  final List<Widget> toolCards;
  final int maxColumns;
  const _CatalogToolGrid({required this.toolCards, required this.maxColumns});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, gridConstraints) {
      const minimumCardWidth = 280.0;
      const cardGap = AppThemeMetrics.cardGap;
      final columnCount =
          ((gridConstraints.maxWidth + cardGap) / (minimumCardWidth + cardGap))
              .floor()
              .clamp(1, maxColumns);
      return Column(
        children: [
          for (
            var firstCardIndex = 0;
            firstCardIndex < toolCards.length;
            firstCardIndex += columnCount
          ) ...[
            if (firstCardIndex > 0) const SizedBox(height: cardGap),
            // Only a few catalog cards: intrinsic height keeps each desktop row
            // aligned while letting long translations and large text expand.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var columnIndex = 0;
                    columnIndex < columnCount;
                    columnIndex++
                  ) ...[
                    if (columnIndex > 0) const SizedBox(width: cardGap),
                    Expanded(
                      child: firstCardIndex + columnIndex < toolCards.length
                          ? toolCards[firstCardIndex + columnIndex]
                          : const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}
