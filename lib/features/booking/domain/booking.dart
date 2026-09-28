// lib/features/booking/domain/booking.dart
import 'package:equatable/equatable.dart';
import 'package:servis_aja/features/booking/domain/enums/booking_status.dart';
import 'package:servis_aja/features/booking/domain/enums/service_status.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';

// ── Snapshots ──────────────────────────────────────────────────────────────
// Snapshots freeze data at booking-creation time so historical records
// remain accurate even if master data changes later.

class WorkshopSnapshot extends Equatable {
  const WorkshopSnapshot({
    required this.name,
    required this.address,
    required this.phone,
  });

  final String name;
  final String address;
  final String phone;

  @override
  List<Object?> get props => [name, address, phone];
}

class SlotSnapshot extends Equatable {
  const SlotSnapshot({required this.date, required this.time});

  final String date; // "2026-10-05"
  final String time; // "09:00"

  String get displayLabel => '$date pukul $time WIB';

  @override
  List<Object?> get props => [date, time];
}

class VehicleSnapshot extends Equatable {
  const VehicleSnapshot({
    required this.plateNumber,
    required this.categoryId,
    required this.brandName,
    required this.modelName,
    this.alias,
    this.year,
  });

  final String plateNumber;
  final String categoryId;
  final String brandName;
  final String modelName;
  final String? alias;
  final int? year;

  String get displayName => alias ?? '$brandName $modelName';

  @override
  List<Object?> get props => [plateNumber, categoryId, brandName, modelName];
}

class ServiceSnapshot extends Equatable {
  const ServiceSnapshot({required this.name, required this.basePrice});

  final String name;
  final int basePrice;

  @override
  List<Object?> get props => [name, basePrice];
}

// ── Status Event ───────────────────────────────────────────────────────────

class StatusEvent extends Equatable {
  const StatusEvent({
    required this.status,
    required this.timestamp,
    this.note,
    this.actorId,
  });

  final String status; // raw string, maps to BookingStatus or ServiceStatus
  final DateTime timestamp;
  final String? note;
  final String? actorId;

  @override
  List<Object?> get props => [status, timestamp];
}

// ── BookingVehicle ─────────────────────────────────────────────────────────

class BookingVehicle extends Equatable {
  const BookingVehicle({
    required this.id,
    required this.bookingId,
    required this.vehicleId,
    required this.vehicleSnapshot,
    required this.serviceTypeId,
    required this.serviceSnapshot,
    required this.selectedParts,
    required this.estimatedCost,
    required this.estimatedDuration,
    required this.serviceStatus,
    required this.statusHistory,
    this.complaint,
    this.assignedMechanicName,
    this.actualCost,
    this.completedAt,
  });

  final String id;
  final String bookingId;
  final String vehicleId;
  final VehicleSnapshot vehicleSnapshot;
  final String serviceTypeId;
  final ServiceSnapshot serviceSnapshot;
  final List<SparePartSelection> selectedParts;
  final String? complaint;
  final int estimatedCost;
  final int estimatedDuration;
  final ServiceStatus serviceStatus;
  final List<StatusEvent> statusHistory;
  final String? assignedMechanicName;
  final int? actualCost;
  final DateTime? completedAt;

  int get partsSubtotal =>
      selectedParts.fold(0, (sum, p) => sum + p.subtotal);

  BookingVehicle copyWith({ServiceStatus? serviceStatus}) => BookingVehicle(
        id: id,
        bookingId: bookingId,
        vehicleId: vehicleId,
        vehicleSnapshot: vehicleSnapshot,
        serviceTypeId: serviceTypeId,
        serviceSnapshot: serviceSnapshot,
        selectedParts: selectedParts,
        complaint: complaint,
        estimatedCost: estimatedCost,
        estimatedDuration: estimatedDuration,
        serviceStatus: serviceStatus ?? this.serviceStatus,
        statusHistory: statusHistory,
        assignedMechanicName: assignedMechanicName,
        actualCost: actualCost,
        completedAt: completedAt,
      );

  @override
  List<Object?> get props => [
        id,
        bookingId,
        vehicleId,
        serviceTypeId,
        serviceStatus,
        selectedParts,
        estimatedCost,
        actualCost,
        assignedMechanicName,
        completedAt,
      ];
}

// ── Booking ────────────────────────────────────────────────────────────────

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.userId,
    required this.workshopId,
    required this.slotId,
    required this.workshopSnapshot,
    required this.slotSnapshot,
    required this.vehicles,
    required this.status,
    required this.statusHistory,
    required this.totalEstimatedCost,
    required this.totalEstimatedDuration,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.confirmedAt,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String workshopId;
  final String slotId;
  final WorkshopSnapshot workshopSnapshot;
  final SlotSnapshot slotSnapshot;
  final List<BookingVehicle> vehicles;
  final BookingStatus status;
  final List<StatusEvent> statusHistory;
  final int totalEstimatedCost;
  final int totalEstimatedDuration;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  int get vehicleCount => vehicles.length;

  bool get allVehiclesCompleted =>
      vehicles.every((v) => v.serviceStatus == ServiceStatus.completed);

  @override
  List<Object?> get props => [
        id,
        userId,
        workshopId,
        slotId,
        status,
        vehicles,
        totalEstimatedCost,
        totalEstimatedDuration,
        updatedAt,
        confirmedAt,
        completedAt,
      ];
}
