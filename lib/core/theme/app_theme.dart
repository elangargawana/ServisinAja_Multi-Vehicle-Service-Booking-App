// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the application ThemeData from design system tokens.
/// All component themes are configured here — no ad-hoc theming in widgets.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = AppColors.colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall,
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.borderSubtle,
      ),

      // ── Card ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
      ),

      // ── ElevatedButton (Primary) ──────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.neutral200;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark;
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.neutral400;
            }
            return AppColors.onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(
            AppColors.onPrimary.withValues(alpha: 0.1),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(88, AppSpacing.buttonHeightLg),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.r12)),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg2),
          ),
        ),
      ),

      // ── OutlinedButton (Secondary) ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.neutral400;
            }
            return AppColors.primary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: AppColors.neutral300);
            }
            return const BorderSide(color: AppColors.primary, width: 1.5);
          }),
          overlayColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.06),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(88, AppSpacing.buttonHeightLg),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.r12)),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg2),
          ),
        ),
      ),

      // ── TextButton (Ghost) ────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.neutral400;
            }
            return AppColors.primary;
          }),
          overlayColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.06),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md3,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textDisabled,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textDanger,
        ),
        helperStyle: AppTypography.bodySmall,
        prefixIconColor: AppColors.neutral400,
        suffixIconColor: AppColors.neutral400,
      ),

      // ── BottomSheet ───────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        modalBarrierColor: AppColors.scrim,
        showDragHandle: false,
      ),

      // ── Dialog ────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLargeRadius,
        ),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
        barrierColor: AppColors.scrim,
      ),

      // ── SnackBar ──────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textInverse,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 0,
      ),

      // ── Chip ──────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        disabledColor: AppColors.neutral100,
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillRadius,
        ),
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── FloatingActionButton ──────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),

      // ── BottomNavigation ──────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral400,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 3,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Progress Indicator ────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: Colors.transparent,
      ),

      // ── Checkbox ──────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.neutral300, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r4),
        ),
      ),

      // ── Radio ─────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.neutral400;
        }),
      ),
    );
  }
}
