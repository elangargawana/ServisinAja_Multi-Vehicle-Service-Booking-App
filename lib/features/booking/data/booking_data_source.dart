// lib/features/booking/data/booking_data_source.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:servis_aja/core/constants/asset_constants.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/domain/enums/booking_status.dart';
import 'package:servis_aja/features/booking/domain/enums/service_status.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';
import 'package:servis_aja/features/booking/domain/service_type.dart';

/// Loads booking history and service type / spare part reference data.
class BookingDataSource {
  List<Booking>? _inMemoryBookings;

  Future<List<Booking>> fetchBookings(String userId) async {
    if (_inMemoryBookings == null) {
      final json = await rootBundle.loadString(AssetConstants.mockBookings);
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = data['bookings'] as List<dynamic>;
      _inMemoryBookings = list.map(_bookingFromJson).toList();
    }
    return _inMemoryBookings!
        .where((b) => b.userId == userId)
        .toList();
  }

  void addBooking(Booking booking) {
    _inMemoryBookings ??= [];
    _inMemoryBookings!.insert(0, booking);
  }

  Booking createBookingFromSession({
    required String bookingId,
    required BookingSession session,
    String userId = 'usr-001',
  }) {
    final now = DateTime.now();
    final ws = session.selectedWorkshop!;
    final slot = session.selectedSlot!;

    final vehicles = session.vehicleConfigs.asMap().entries.map((entry) {
      final idx = entry.key;
      final config = entry.value;
      final v = config.vehicle;
      final s = config.selectedService!;

      return BookingVehicle(
        id: 'bv-$bookingId-$idx',
        bookingId: bookingId,
        vehicleId: v.id,
        vehicleSnapshot: VehicleSnapshot(
          plateNumber: v.plateNumber,
          categoryId: v.categoryId,
          brandName: v.brandName,
          modelName: v.modelName,
          alias: v.alias,
          year: v.year,
        ),
        serviceTypeId: s.id,
        serviceSnapshot: ServiceSnapshot(
          name: s.name,
          basePrice: s.basePriceFor(v.categoryId),
        ),
        selectedParts: config.selectedParts,
        complaint:
            config.complaintText.isNotEmpty ? config.complaintText : null,
        estimatedCost: config.estimatedCost,
        estimatedDuration: config.estimatedDuration,
        serviceStatus: ServiceStatus.waitingArrival,
        statusHistory: [
          StatusEvent(
            status: 'waiting_arrival',
            timestamp: now,
            note: 'Booking berhasil dikonfirmasi',
            actorId: 'system',
          ),
        ],
      );
    }).toList();

    final booking = Booking(
      id: bookingId,
      userId: userId,
      workshopId: ws.id,
      slotId: slot.id,
      workshopSnapshot: WorkshopSnapshot(
        name: ws.name,
        address: ws.address,
        phone: ws.phone,
      ),
      slotSnapshot: SlotSnapshot(
        date: slot.date,
        time: slot.time,
      ),
      vehicles: vehicles,
      status: BookingStatus.confirmed,
      statusHistory: [
        StatusEvent(
          status: 'confirmed',
          timestamp: now,
          note: 'Booking terkonfirmasi sistem',
          actorId: 'system',
        ),
      ],
      totalEstimatedCost: session.totalEstimatedCost,
      totalEstimatedDuration: session.totalEstimatedDuration,
      createdAt: now,
      updatedAt: now,
      confirmedAt: now,
    );

    addBooking(booking);
    return booking;
  }

  Future<List<ServiceType>> fetchServiceTypes() async {
    final json = await rootBundle.loadString(AssetConstants.mockServiceTypes);
    final list = jsonDecode(json) as List<dynamic>;
    return list.map(_serviceTypeFromJson).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<SparePart>> fetchSpareParts() async {
    final json = await rootBundle.loadString(AssetConstants.mockSpareParts);
    final list = jsonDecode(json) as List<dynamic>;
    return list.map(_sparePartFromJson).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // ── Mapping helpers ──────────────────────────────────────────────

  Booking _bookingFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    final wsSnap = m['workshopSnapshot'] as Map<String, dynamic>;
    final slotSnap = m['slotSnapshot'] as Map<String, dynamic>;
    final vehiclesRaw = m['vehicles'] as List<dynamic>;

    return Booking(
      id: m['id'] as String,
      userId: m['userId'] as String,
      workshopId: m['workshopId'] as String,
      slotId: m['slotId'] as String,
      workshopSnapshot: WorkshopSnapshot(
        name: wsSnap['name'] as String,
        address: wsSnap['address'] as String,
        phone: wsSnap['phone'] as String,
      ),
      slotSnapshot: SlotSnapshot(
        date: slotSnap['date'] as String,
        time: slotSnap['time'] as String,
      ),
      status: BookingStatus.fromString(m['status'] as String),
      statusHistory: _statusEventsFromJson(m['statusHistory'] as List<dynamic>),
      totalEstimatedCost: m['totalEstimatedCost'] as int,
      totalEstimatedDuration: m['totalEstimatedDuration'] as int,
      notes: m['notes'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
      confirmedAt: m['confirmedAt'] != null
          ? DateTime.tryParse(m['confirmedAt'] as String)
          : null,
      completedAt: m['completedAt'] != null
          ? DateTime.tryParse(m['completedAt'] as String)
          : null,
      vehicles: vehiclesRaw.map(_bookingVehicleFromJson).toList(),
    );
  }

  BookingVehicle _bookingVehicleFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    final vsSnap = m['vehicleSnapshot'] as Map<String, dynamic>;
    final ssSnap = m['serviceSnapshot'] as Map<String, dynamic>;
    final partsRaw = m['selectedParts'] as List<dynamic>;

    return BookingVehicle(
      id: m['id'] as String,
      bookingId: m['bookingId'] as String,
      vehicleId: m['vehicleId'] as String,
      vehicleSnapshot: VehicleSnapshot(
        plateNumber: vsSnap['plateNumber'] as String,
        categoryId: vsSnap['categoryId'] as String,
        brandName: vsSnap['brandName'] as String,
        modelName: vsSnap['modelName'] as String,
        alias: vsSnap['alias'] as String?,
        year: vsSnap['year'] as int?,
      ),
      serviceTypeId: m['serviceTypeId'] as String,
      serviceSnapshot: ServiceSnapshot(
        name: ssSnap['name'] as String,
        basePrice: ssSnap['basePrice'] as int,
      ),
      selectedParts: partsRaw.map(_sparePartSelectionFromJson).toList(),
      complaint: m['complaint'] as String?,
      estimatedCost: m['estimatedCost'] as int,
      estimatedDuration: m['estimatedDuration'] as int,
      serviceStatus: ServiceStatus.fromString(m['serviceStatus'] as String),
      statusHistory:
          _statusEventsFromJson(m['statusHistory'] as List<dynamic>),
      assignedMechanicName: m['assignedMechanicName'] as String?,
      actualCost: m['actualCost'] as int?,
      completedAt: m['completedAt'] != null
          ? DateTime.tryParse(m['completedAt'] as String)
          : null,
    );
  }

  SparePartSelection _sparePartSelectionFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return SparePartSelection(
      partId: m['partId'] as String,
      name: m['name'] as String,
      brand: m['brand'] as String,
      quantity: m['quantity'] as int,
      unitPrice: m['unitPrice'] as int,
    );
  }

  List<StatusEvent> _statusEventsFromJson(List<dynamic> raw) {
    return raw.map((j) {
      final m = j as Map<String, dynamic>;
      return StatusEvent(
        status: m['status'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        note: m['note'] as String?,
        actorId: m['actorId'] as String?,
      );
    }).toList();
  }

  ServiceType _serviceTypeFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return ServiceType(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      compatibleCategories:
          List<String>.from(m['compatibleCategories'] as List),
      basePriceMotor: m['basePriceMotor'] as int?,
      basePriceMobil: m['basePriceMobil'] as int?,
      estimatedDurationMotor: m['estimatedDuration'] as int,
      estimatedDurationMobil: m['estimatedDurationMobil'] as int?,
      iconName: m['iconName'] as String,
      colorHex: m['colorHex'] as String,
      recommendedSparePartIds:
          List<String>.from(m['recommendedSparePartIds'] as List),
      sortOrder: m['sortOrder'] as int,
    );
  }

  SparePart _sparePartFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return SparePart(
      id: m['id'] as String,
      name: m['name'] as String,
      brand: m['brand'] as String,
      description: m['description'] as String?,
      category: m['category'] as String,
      compatibleVehicleCategories:
          List<String>.from(m['compatibleVehicleCategories'] as List),
      compatibleServiceIds:
          List<String>.from(m['compatibleServiceIds'] as List),
      priceMotor: m['priceMotor'] as int?,
      priceMobil: m['priceMobil'] as int?,
      unit: m['unit'] as String,
      isRecommended: m['isRecommended'] as bool,
      sortOrder: m['sortOrder'] as int,
    );
  }
}
