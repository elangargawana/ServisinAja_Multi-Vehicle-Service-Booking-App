// lib/core/constants/app_constants.dart

/// Application-level string and numeric constants.
abstract final class AppConstants {
  static const String appName = 'ServisinAja';
  static const String appVersion = '1.0.0';

  // ── Booking Rules ─────────────────────────────────────────────────
  /// Maximum vehicles per booking session
  static const int maxVehiclesPerBooking = 5;

  /// Maximum characters for complaint/notes text
  static const int maxComplaintLength = 300;

  /// Mock API simulate delay in milliseconds (default)
  static const int mockDelayMs = 800;

  /// Mock API simulate delay in milliseconds (fast operations)
  static const int mockDelayFastMs = 400;

  /// Mock API simulate delay in milliseconds (booking submission)
  static const int mockDelaySlowMs = 1500;

  // ── Booking ID Format ─────────────────────────────────────────────
  /// Prefix for booking IDs: SRV-YYYYMMDD-XXXX
  static const String bookingIdPrefix = 'SRV';

  // ── Slot Thresholds ───────────────────────────────────────────────
  /// Slot is "almost full" when available <= 50% of capacity
  static const double slotAlmostFullThreshold = 0.5;

  // ── Maps Deep Link ────────────────────────────────────────────────
  static const String googleMapsBaseUrl =
      'https://www.google.com/maps/search/?api=1&query=';
}
