import 'package:flutter/material.dart';

/// A feature-scoped expression of PixiDesk's existing neutral light/dark theme.
class StudioColors {
  final bool dark;
  final Color ink, muted, faint, panel, canvas, field, line, selected;
  StudioColors(BuildContext context)
    : dark = Theme.of(context).brightness == Brightness.dark,
      ink = Theme.of(context).colorScheme.onSurface,
      muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
      faint = Theme.of(context).colorScheme.onSurface.withValues(alpha: .32),
      panel = Color.alphaBlend(
        Colors.white.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? .025 : .78,
        ),
        Theme.of(context).colorScheme.surface,
      ),
      canvas = Color.alphaBlend(
        Colors.black.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? .22 : .025,
        ),
        Theme.of(context).colorScheme.surface,
      ),
      field = Theme.of(context).colorScheme.onSurface.withValues(alpha: .035),
      line = Theme.of(context).colorScheme.onSurface.withValues(alpha: .08),
      selected = Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: .065);
}

class ImageStudioTheme extends StatelessWidget {
  final Widget child;
  const ImageStudioTheme({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final c = StudioColors(context);
    final family = base.textTheme.bodyMedium?.fontFamily;
    final fallback = base.textTheme.bodyMedium?.fontFamilyFallback;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c.line),
    );
    final text = base.textTheme.apply(
      fontSizeFactor: .9,
      bodyColor: c.ink,
      displayColor: c.ink,
    );
    return Theme(
      data: base.copyWith(
        appBarTheme: base.appBarTheme.copyWith(
          titleTextStyle: text.titleLarge?.copyWith(fontFamily: family),
        ),
        textTheme: text.copyWith(
          titleLarge: text.titleLarge?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: -.4,
          ),
          titleMedium: text.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: text.bodyMedium?.copyWith(fontSize: 13, height: 1.5),
          bodySmall: text.bodySmall?.copyWith(
            fontSize: 11,
            height: 1.5,
            color: c.muted,
          ),
          labelLarge: text.labelLarge?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerColor: c.line,
        dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: c.field,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: c.ink.withValues(alpha: .5)),
          ),
          labelStyle: TextStyle(fontSize: 12, color: c.muted),
          hintStyle: TextStyle(fontSize: 12, color: c.faint),
          floatingLabelStyle: TextStyle(fontSize: 12, color: c.muted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: c.ink,
            foregroundColor: base.colorScheme.surface,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            textStyle: TextStyle(
              fontFamily: family,
              fontFamilyFallback: fallback,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: c.ink,
            foregroundColor: base.colorScheme.surface,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: c.ink,
            side: BorderSide(color: c.line),
            minimumSize: const Size(0, 38),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: TextStyle(
              fontFamily: family,
              fontFamilyFallback: fallback,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: c.muted,
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: TextStyle(
              fontFamily: family,
              fontFamilyFallback: fallback,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: c.muted,
            iconSize: 18,
            minimumSize: const Size(34, 34),
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        sliderTheme: base.sliderTheme.copyWith(
          activeTrackColor: c.ink,
          inactiveTrackColor: c.line,
          thumbColor: c.ink,
          overlayColor: c.ink.withValues(alpha: .06),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        ),
        switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.ink : c.line,
          ),
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? base.colorScheme.surface
                : c.muted,
          ),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        chipTheme: base.chipTheme.copyWith(
          side: BorderSide(color: c.line),
          backgroundColor: c.field,
          selectedColor: c.selected,
          labelStyle: TextStyle(color: c.ink, fontSize: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          shape: const Border(),
          collapsedShape: const Border(),
          textColor: c.ink,
          collapsedTextColor: c.ink,
          iconColor: c.muted,
          collapsedIconColor: c.muted,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 12),
        ),
        tooltipTheme: base.tooltipTheme.copyWith(
          waitDuration: const Duration(milliseconds: 400),
        ),
      ),
      child: child,
    );
  }
}

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
    final c = StudioColors(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? c.panel,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minimum =
              minimumContentHeight *
              (MediaQuery.textScalerOf(context).scale(1) > 1.4 ? 1.5 : 1);
          if (constraints.maxHeight.isFinite &&
              constraints.maxHeight < minimum) {
            return SingleChildScrollView(
              child: SizedBox(height: minimum, child: child),
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
    final c = StudioColors(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.field,
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
                    color: selected == index ? c.panel : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == index
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: c.dark ? .1 : .045,
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
                      color: selected == index ? c.ink : c.muted,
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
