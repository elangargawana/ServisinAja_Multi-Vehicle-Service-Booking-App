// lib/features/booking/presentation/providers/booking_computed_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';

/// Derived/computed providers from BookingSession.
/// Widgets watch these instead of the full session for granular rebuilds.

/// Total estimated cost for all vehicles in current session (IDR).
final totalEstimatedCostProvider = Provider<int>((ref) {
  return ref.watch(bookingSessionProvider).totalEstimatedCost;
});

/// Total estimated duration for all vehicles in current session (minutes).
final totalEstimatedDurationProvider = Provider<int>((ref) {
  return ref.watch(bookingSessionProvider).totalEstimatedDuration;
});

/// True when the session is complete and the user can proceed to submit.
final isBookingReadyProvider = Provider<bool>((ref) {
  return ref.watch(bookingSessionProvider).isReadyToSubmit;
});

/// True when all vehicles have a service configured (workshop not required).
/// Used by GarageScreen to enable the "Pilih Bengkel" CTA.
final isVehiclesReadyProvider = Provider<bool>((ref) {
  final session = ref.watch(bookingSessionProvider);
  return session.vehicleConfigs.isNotEmpty &&
      session.vehicleConfigs.every((c) => c.isConfigured);
});

/// Count of vehicles not yet configured (service not selected).
final unconfiguredVehicleCountProvider = Provider<int>((ref) {
  return ref.watch(bookingSessionProvider).unconfiguredCount;
});

/// True when the max vehicle limit has been reached.
final canAddMoreVehiclesProvider = Provider<bool>((ref) {
  return ref.watch(bookingSessionProvider).canAddVehicle;
});

/// Number of vehicles in the current session.
final vehicleCountProvider = Provider<int>((ref) {
  return ref.watch(bookingSessionProvider).vehicleConfigs.length;
});
