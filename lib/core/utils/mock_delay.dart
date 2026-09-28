// lib/core/utils/mock_delay.dart
import 'package:servis_aja/core/constants/app_constants.dart';

/// Simulates async API latency for mock data repositories.
/// In tests, use [enableTestMode] to skip delays.
abstract final class MockDelay {
  static bool _testMode = false;

  /// Call this in test setUp() to eliminate delays in unit tests.
  static void enableTestMode() => _testMode = true;

  /// Resets test mode (use in tearDown if needed).
  static void disableTestMode() => _testMode = false;

  /// Standard operation delay (~800ms).
  static Future<void> simulate() async {
    if (_testMode) return;
    await Future.delayed(
      const Duration(milliseconds: AppConstants.mockDelayMs),
    );
  }

  /// Fast operation delay (~400ms) for simple reads.
  static Future<void> fast() async {
    if (_testMode) return;
    await Future.delayed(
      const Duration(milliseconds: AppConstants.mockDelayFastMs),
    );
  }

  /// Slow operation delay (~1500ms) for booking submission.
  static Future<void> slow() async {
    if (_testMode) return;
    await Future.delayed(
      const Duration(milliseconds: AppConstants.mockDelaySlowMs),
    );
  }
}
