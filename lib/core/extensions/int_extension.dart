// lib/core/extensions/int_extension.dart
import 'package:intl/intl.dart';

extension IntExtension on int {
  /// Formats the integer as Indonesian Rupiah currency.
  /// Example: 150000 → "Rp 150.000"
  String toCurrency() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Formats the integer as a compact Rupiah string for display.
  /// Example: 1500000 → "Rp 1,5 jt"
  String toCurrencyCompact() {
    if (this >= 1000000) {
      final value = this / 1000000;
      final formatted = value == value.truncate()
          ? value.truncate().toString()
          : value.toStringAsFixed(1);
      return 'Rp $formatted jt';
    }
    if (this >= 1000) {
      final value = this / 1000;
      final formatted = value == value.truncate()
          ? value.truncate().toString()
          : value.toStringAsFixed(1);
      return 'Rp ${formatted}rb';
    }
    return toCurrency();
  }

  /// Formats duration in minutes to human-readable string.
  /// Example: 90 → "~1 Jam 30 Mnt"  |  60 → "~1 Jam"  |  30 → "~30 Mnt"
  String toDurationLabel() {
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (hours > 0 && minutes > 0) return '~$hours Jam $minutes Mnt';
    if (hours > 0) return '~$hours Jam';
    return '~$minutes Mnt';
  }
}
