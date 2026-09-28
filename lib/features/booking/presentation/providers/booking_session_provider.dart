// lib/features/booking/presentation/providers/booking_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/core/constants/app_constants.dart';
import 'package:servis_aja/core/errors/app_exception.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';
import 'package:servis_aja/features/booking/domain/service_type.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

/// Manages the active booking session throughout the booking flow.
/// Lives from Workshop Selection → Booking Success, then resets.
class BookingSessionNotifier extends StateNotifier<BookingSession> {
  BookingSessionNotifier() : super(const BookingSession());

  // ── Workshop & Schedule ──────────────────────────────────────────

  void setWorkshop(Workshop workshop) {
    // Validasi apakah bengkel mendukung seluruh kategori kendaraan yang sudah dipilih
    for (final config in state.vehicleConfigs) {
      if (!workshop.supportsCategory(config.vehicle.categoryId)) {
        final wsCat = workshop.categories
            .map((c) => c == 'mobil' ? 'Mobil' : 'Motor')
            .join(' & ');
        final vCat = config.vehicle.isMobil ? 'Mobil' : 'Motor';
        throw BusinessRuleException(
          message:
              '${workshop.name} hanya melayani $wsCat, tidak melayani $vCat (${config.vehicle.displayName}).',
        );
      }
    }

    state = state.copyWith(
      selectedWorkshop: workshop,
      clearSlot: true, // slot must be re-selected for new workshop
    );
  }

  void setSchedule(WorkshopSlot slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  // ── Vehicle Management ───────────────────────────────────────────

  void addVehicle(Vehicle vehicle) {
    if (!state.canAddVehicle) {
      throw BusinessRuleException(
        message:
            'Maksimal ${AppConstants.maxVehiclesPerBooking} kendaraan per booking.',
      );
    }
    if (state.vehicleAlreadyAdded(vehicle.id)) {
      throw DuplicateException(
        message: 'Kendaraan ${vehicle.displayName} sudah ditambahkan.',
      );
    }
    // Jika bengkel sudah dipilih sebelumnya, pastikan kendaraan ini didukung oleh bengkel tersebut
    if (state.selectedWorkshop != null &&
        !state.selectedWorkshop!.supportsCategory(vehicle.categoryId)) {
      final wsCat = state.selectedWorkshop!.categories
          .map((c) => c == 'mobil' ? 'Mobil' : 'Motor')
          .join(' & ');
      final vCat = vehicle.isMobil ? 'Mobil' : 'Motor';
      throw BusinessRuleException(
        message:
            '${state.selectedWorkshop!.name} hanya melayani $wsCat, tidak dapat menambahkan $vCat.',
      );
    }
    final updated = [...state.vehicleConfigs, VehicleConfig(vehicle: vehicle)];
    state = state.copyWith(vehicleConfigs: updated);
  }

  void removeVehicle(String vehicleId) {
    final updated = state.vehicleConfigs
        .where((c) => c.vehicle.id != vehicleId)
        .toList();
    state = state.copyWith(vehicleConfigs: updated);
  }

  // ── Vehicle Configuration ────────────────────────────────────────

  void setServiceForVehicle(String vehicleId, ServiceType service) {
    final updated = _updateConfig(
      vehicleId,
      (c) => c.copyWith(selectedService: service, selectedParts: [], clearService: false),
    );
    state = state.copyWith(vehicleConfigs: updated);
  }

  void addPartForVehicle(String vehicleId, SparePart part) {
    final config = state.configFor(vehicleId);
    if (config == null) return;

    final price = part.priceFor(config.vehicle.categoryId);
    if (price == null) return; // incompatible part

    final existing = config.selectedParts
        .indexWhere((p) => p.partId == part.id);

    List<SparePartSelection> updatedParts;
    if (existing >= 0) {
      // Increment quantity if already selected
      updatedParts = List.from(config.selectedParts);
      updatedParts[existing] =
          updatedParts[existing].copyWith(quantity: updatedParts[existing].quantity + 1);
    } else {
      updatedParts = [
        ...config.selectedParts,
        SparePartSelection(
          partId: part.id,
          name: part.name,
          brand: part.brand,
          quantity: 1,
          unitPrice: price,
        ),
      ];
    }

    final updated = _updateConfig(
      vehicleId,
      (c) => c.copyWith(selectedParts: updatedParts),
    );
    state = state.copyWith(vehicleConfigs: updated);
  }

  void removePartForVehicle(String vehicleId, String partId) {
    final updated = _updateConfig(
      vehicleId,
      (c) => c.copyWith(
        selectedParts:
            c.selectedParts.where((p) => p.partId != partId).toList(),
      ),
    );
    state = state.copyWith(vehicleConfigs: updated);
  }

  void updateComplaint(String vehicleId, String text) {
    final updated = _updateConfig(
      vehicleId,
      (c) => c.copyWith(complaintText: text),
    );
    state = state.copyWith(vehicleConfigs: updated);
  }

  /// Replaces the config for [vehicleId] with [updatedConfig].
  /// Called from VehicleConfigScreen when user taps "Simpan".
  void saveVehicleConfig(String vehicleId, VehicleConfig updatedConfig) {
    final updated = state.vehicleConfigs
        .map((c) => c.vehicle.id == vehicleId ? updatedConfig : c)
        .toList();
    state = state.copyWith(vehicleConfigs: updated);
  }

  // ── Session Lifecycle ────────────────────────────────────────────

  /// Called after successful booking submission.
  void resetSession() {
    state = const BookingSession();
  }

  // ── Private helpers ──────────────────────────────────────────────

  List<VehicleConfig> _updateConfig(
    String vehicleId,
    VehicleConfig Function(VehicleConfig) transform,
  ) {
    return state.vehicleConfigs.map((c) {
      return c.vehicle.id == vehicleId ? transform(c) : c;
    }).toList();
  }
}

/// The global booking session provider.
/// Not autoDispose — must persist across route pushes in booking flow.
final bookingSessionProvider =
    StateNotifierProvider<BookingSessionNotifier, BookingSession>(
  (ref) => BookingSessionNotifier(),
);
