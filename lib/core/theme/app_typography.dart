// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for ServisinAja.
/// Primary font: Plus Jakarta Sans — geometric sans-serif, modern & warm.
/// Mono font: JetBrains Mono — for Booking IDs and plate numbers.
abstract final class AppTypography {
  // ── Font Families ─────────────────────────────────────────────────
  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;

  // ── Display ───────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.01 * 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: -0.01 * 28,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: -0.005 * 24,
        color: AppColors.textPrimary,
      );

  // ── Headline ──────────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ── Title ─────────────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.001 * 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.001 * 12,
        color: AppColors.textPrimary,
      );

  // ── Body ──────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.0025 * 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.004 * 12,
        color: AppColors.textTertiary,
      );

  // ── Label ─────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.001 * 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.005 * 12,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.005 * 11,
        color: AppColors.textPrimary,
      );

  // ── Monospace (Booking ID, plate numbers) ─────────────────────────
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoMedium => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 1.0,
        color: AppColors.textSecondary,
      );

  // ── TextTheme for ThemeData ────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
