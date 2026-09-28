// lib/features/booking/domain/booking_session.dart
import 'package:equatable/equatable.dart';
import 'package:servis_aja/core/constants/app_constants.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';
import 'package:servis_aja/features/booking/domain/service_type.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

/// Working draft for a single vehicle's service configuration.
/// Exists only during booking flow — converted to BookingVehicle on submit.
class VehicleConfig extends Equatable {
  const VehicleConfig({
    required this.vehicle,
    this.selectedService,
    this.selectedParts = const [],
    this.complaintText = '',
  });

  final Vehicle vehicle;
  final ServiceType? selectedService;
  final List<SparePartSelection> selectedParts;
  final String complaintText;

  /// A vehicle config is "complete" when a service type is chosen.
  bool get isConfigured => selectedService != null;

  int get estimatedCost {
    if (selectedService == null) return 0;
    final base = selectedService!.basePriceFor(vehicle.categoryId);
    final parts = selectedParts.fold(0, (sum, p) => sum + p.subtotal);
    return base + parts;
  }

  int get estimatedDuration {
    return selectedService?.durationFor(vehicle.categoryId) ?? 0;
  }

  int get partsSubtotal =>
      selectedParts.fold(0, (sum, p) => sum + p.subtotal);

  VehicleConfig copyWith({
    ServiceType? selectedService,
    List<SparePartSelection>? selectedParts,
    String? complaintText,
    bool clearService = false,
  }) =>
      VehicleConfig(
        vehicle: vehicle,
        selectedService:
            clearService ? null : (selectedService ?? this.selectedService),
        selectedParts: selectedParts ?? this.selectedParts,
        complaintText: complaintText ?? this.complaintText,
      );

  @override
  List<Object?> get props => [vehicle.id, selectedService, selectedParts, complaintText];
}

/// The top-level state held by BookingSessionNotifier.
/// Represents everything the user has chosen for the current booking.
class BookingSession extends Equatable {
  const BookingSession({
    this.selectedWorkshop,
    this.selectedSlot,
    this.vehicleConfigs = const [],
  });

  final Workshop? selectedWorkshop;
  final WorkshopSlot? selectedSlot;
  final List<VehicleConfig> vehicleConfigs;

  // ── Computed ────────────────────────────────────────────────────
  int get totalEstimatedCost =>
      vehicleConfigs.fold(0, (sum, c) => sum + c.estimatedCost);

  int get totalEstimatedDuration =>
      vehicleConfigs.fold(0, (sum, c) => sum + c.estimatedDuration);

  bool get hasWorkshopAndSlot =>
      selectedWorkshop != null && selectedSlot != null;

  bool get isReadyToSubmit =>
      hasWorkshopAndSlot &&
      vehicleConfigs.isNotEmpty &&
      vehicleConfigs.every((c) => c.isConfigured) &&
      vehicleConfigs.length <= AppConstants.maxVehiclesPerBooking;

  bool get canAddVehicle =>
      vehicleConfigs.length < AppConstants.maxVehiclesPerBooking;

  int get configuredCount =>
      vehicleConfigs.where((c) => c.isConfigured).length;

  int get unconfiguredCount => vehicleConfigs.length - configuredCount;

  bool vehicleAlreadyAdded(String vehicleId) =>
      vehicleConfigs.any((c) => c.vehicle.id == vehicleId);

  VehicleConfig? configFor(String vehicleId) {
    try {
      return vehicleConfigs.firstWhere((c) => c.vehicle.id == vehicleId);
    } catch (_) {
      return null;
    }
  }

  BookingSession copyWith({
    Workshop? selectedWorkshop,
    WorkshopSlot? selectedSlot,
    List<VehicleConfig>? vehicleConfigs,
    bool clearWorkshop = false,
    bool clearSlot = false,
  }) =>
      BookingSession(
        selectedWorkshop:
            clearWorkshop ? null : (selectedWorkshop ?? this.selectedWorkshop),
        selectedSlot:
            clearSlot ? null : (selectedSlot ?? this.selectedSlot),
        vehicleConfigs: vehicleConfigs ?? this.vehicleConfigs,
      );

  @override
  List<Object?> get props => [selectedWorkshop, selectedSlot, vehicleConfigs];
}
