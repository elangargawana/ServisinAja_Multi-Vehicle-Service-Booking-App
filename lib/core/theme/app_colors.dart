// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// All color constants for ServisinAja design system.
/// Never use raw hex values in widgets — always reference these tokens.
abstract final class AppColors {
  // ── Brand / Primary Orange ──────────────────────────────────────
  static const Color primary = Color(0xFFF26522);
  static const Color primaryDark = Color(0xFFC44000);
  static const Color primaryLight = Color(0xFFF5834A);
  static const Color primaryContainer = Color(0xFFFEE9DB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF6E2200);

  // ── Secondary Slate ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF334155);
  static const Color secondaryContainer = Color(0xFFF1F5F9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1E293B);

  // ── Semantic: Success ────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF15803D);

  // ── Semantic: Warning ────────────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFB45309);

  // ── Semantic: Error ──────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFB91C1C);

  // ── Semantic: Info ───────────────────────────────────────────────
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF1D4ED8);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF1D4ED8);

  // ── Neutral ──────────────────────────────────────────────────────
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  // ── Surface & Background ─────────────────────────────────────────
  static const Color background = neutral50;
  static const Color surface = white;
  static const Color surfaceVariant = neutral100;
  static const Color scrim = Color(0x80111827); // neutral900 at 50%

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;
  static const Color textTertiary = neutral500;
  static const Color textDisabled = neutral400;
  static const Color textInverse = white;
  static const Color textBrand = primaryDark; // orange-700 for AA on white
  static const Color textDanger = errorDark;
  static const Color textSuccess = successDark;
  static const Color textWarning = warningDark;

  // ── Border ───────────────────────────────────────────────────────
  static const Color borderDefault = neutral300;
  static const Color borderSubtle = neutral200;
  static const Color borderBrand = primary;
  static const Color borderDanger = error;
  static const Color borderSuccess = success;

  // ── Gradients ────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE05210), Color(0xFF9E3100)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xB3000000)],
  );

  // ── ColorScheme for ThemeData ─────────────────────────────────────
  static ColorScheme get colorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        outline: borderDefault,
        outlineVariant: borderSubtle,
        shadow: Color(0x1A000000),
        scrim: scrim,
        inverseSurface: neutral900,
        onInverseSurface: white,
        inversePrimary: primaryLight,
      );
}
