// lib/core/extensions/datetime_extension.dart
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formats date for display in booking context.
  /// Example: "Senin, 5 Oktober 2026"
  String toDisplayDate() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(this);
  }

  /// Short date format. Example: "5 Okt 2026"
  String toShortDate() {
    return DateFormat('d MMM yyyy', 'id_ID').format(this);
  }

  /// Time format. Example: "09:00"
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Date key used for slot grouping. Example: "2026-10-05"
  String toDateKey() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Day of week abbreviation. Example: "Sen", "Sel"
  String toDayAbbr() {
    return DateFormat('EEE', 'id_ID').format(this);
  }

  /// Day number only. Example: "5"
  String toDayNumber() {
    return day.toString();
  }

  /// Short month abbreviation. Example: "Okt", "Jan"
  String toShortMonth() {
    return DateFormat('MMM', 'id_ID').format(this);
  }

  /// Long human-readable date. Example: "Senin, 5 Oktober 2026"
  String toLongDate() {
    return DateFormat('EEE, d MMM yyyy', 'id_ID').format(this);
  }

  /// Checks if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date is in the past (before today).
  bool get isPast {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final thisOnly = DateTime(year, month, day);
    return thisOnly.isBefore(todayOnly);
  }
}
