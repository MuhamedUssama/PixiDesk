/// Shared desktop sizing and motion. Content height remains intrinsic so text
/// scaling and Arabic copy can grow without clipping.
abstract final class AppThemeMetrics {
  static const double pageMaxWidth = 1120;
  static const double pagePadding = 32;
  static const double compactPagePadding = 20;
  static const double cardPadding = 24;
  static const double cardRadius = 18;
  static const double controlRadius = 10;
  static const double cardGap = 16;
  static const double sectionGap = 32;
  static const Duration interactionDuration = Duration(milliseconds: 160);
}
