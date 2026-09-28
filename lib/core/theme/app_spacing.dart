// lib/core/theme/app_spacing.dart

/// Spacing constants based on an 8px grid system.
/// Use these tokens instead of raw numbers in all widgets.
abstract final class AppSpacing {
  // ── Base Scale ───────────────────────────────────────────────────
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm2 = 6.0;
  static const double sm = 8.0;
  static const double md2 = 10.0;
  static const double md = 16.0;
  static const double md3 = 12.0;
  static const double lg = 20.0;
  static const double lg2 = 24.0;
  static const double xl = 28.0;
  static const double xl2 = 32.0;
  static const double xl3 = 40.0;
  static const double xl4 = 48.0;
  static const double xl5 = 56.0;
  static const double xl6 = 64.0;
  static const double xl7 = 72.0;
  static const double xl8 = 80.0;

  // ── Semantic Aliases ─────────────────────────────────────────────
  /// Default horizontal page margin applied to all screens
  static const double pageHorizontal = md; // 16px

  /// Default vertical padding at top of main content
  static const double pageVertical = lg; // 20px

  /// Gap between cards in a list
  static const double cardGap = md3; // 12px

  /// Default padding inside cards
  static const double cardPadding = md; // 16px

  /// Compact padding inside dense cards
  static const double cardPaddingCompact = md3; // 12px

  /// Gap between major sections on a screen
  static const double sectionGap = lg2; // 24px

  /// Gap between section header and its content
  static const double sectionHeaderGap = md3; // 12px

  /// Gap between icon and its label
  static const double iconTextGap = sm; // 8px

  /// Gap between inline row elements
  static const double inlineGap = sm; // 8px

  // ── Touch Targets ────────────────────────────────────────────────
  static const double minTouchTarget = 48.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightSm = 36.0;
  static const double chipHeight = 32.0;
  static const double badgeMinHeight = 24.0;

  // ── App Bar ──────────────────────────────────────────────────────
  static const double appBarHeight = 56.0;
  static const double bottomBarHeight = 72.0;
}
