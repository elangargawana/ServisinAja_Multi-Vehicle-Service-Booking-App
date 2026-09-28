// lib/core/utils/booking_id_generator.dart
import 'dart:math';

/// Generates human-readable booking IDs in the format SRV-YYYYMMDD-XXXX.
abstract final class BookingIdGenerator {
  static final _random = Random();

  /// Generates a booking ID.
  /// Example: "SRV-20261005-0042"
  static String generate({DateTime? date}) {
    final now = date ?? DateTime.now();
    final datePart =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = (_random.nextInt(9000) + 1000).toString().padLeft(4, '0');
    return 'SRV-$datePart-$seq';
  }
}
