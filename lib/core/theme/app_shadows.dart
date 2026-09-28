// lib/core/theme/app_shadows.dart
import 'package:flutter/material.dart';

/// Elevation shadow definitions for ServisinAja design system.
/// 5-level system matching design document.
abstract final class AppShadows {
  // ── Elevation Levels ─────────────────────────────────────────────

  /// Level 0 — No shadow. Used for flat backgrounds, dividers.
  static const List<BoxShadow> none = [];

  /// Level 1 — Card resting state.
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Level 2 — Card hover / active bottom sheet.
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 3 — FAB, sticky bottom bar, dropdown.
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 4 — Modal, dialog, expanded bottom sheet.
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 10),
    ),
  ];
}
