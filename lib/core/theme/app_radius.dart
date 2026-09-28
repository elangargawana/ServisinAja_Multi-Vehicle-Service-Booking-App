// lib/core/theme/app_radius.dart
import 'package:flutter/material.dart';

/// Border radius constants for ServisinAja design system.
abstract final class AppRadius {
  static const double r2 = 2.0;
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double full = 999.0;

  // ── Semantic Aliases ─────────────────────────────────────────────
  /// Used for: input fields, thumbnail images, small cards
  static const double input = r8;

  /// Default card radius — used by all standard cards
  static const double card = r12;

  /// Used for: booking ID card, ticket card, modal card
  static const double cardLarge = r16;

  /// Used for: bottom sheet top corners
  static const double sheet = r20;

  /// Used for: FAB, pill buttons
  static const double fab = r24;

  /// Used for: status badges, avatar, chip pills
  static const double pill = full;

  // ── BorderRadius convenience getters ─────────────────────────────
  static BorderRadius get cardRadius =>
      BorderRadius.circular(card);

  static BorderRadius get cardLargeRadius =>
      BorderRadius.circular(cardLarge);

  static BorderRadius get inputRadius =>
      BorderRadius.circular(input);

  static BorderRadius get sheetRadius => const BorderRadius.vertical(
        top: Radius.circular(sheet),
      );

  static BorderRadius get pillRadius =>
      BorderRadius.circular(pill);
}
