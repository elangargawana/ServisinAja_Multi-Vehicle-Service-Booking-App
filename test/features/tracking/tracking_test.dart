// test/features/tracking/tracking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/enums/booking_status.dart';
import 'package:servis_aja/features/booking/domain/enums/service_status.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

void main() {
  group('ServiceStatus pipeline tests', () {
    test('ServiceStatus mapping from string works correctly', () {
      expect(ServiceStatus.fromString('waiting_arrival'), ServiceStatus.waitingArrival);
      expect(ServiceStatus.fromString('arrived'), ServiceStatus.arrived);
      expect(ServiceStatus.fromString('being_inspected'), ServiceStatus.beingInspected);
      expect(ServiceStatus.fromString('in_service'), ServiceStatus.inService);
      expect(ServiceStatus.fromString('quality_check'), ServiceStatus.qualityCheck);
      expect(ServiceStatus.fromString('completed'), ServiceStatus.completed);
      expect(ServiceStatus.fromString('unknown_status'), ServiceStatus.waitingArrival);
    });

    test('ServiceStatus flags are accurate', () {
      expect(ServiceStatus.waitingArrival.isActive, isFalse);
      expect(ServiceStatus.waitingArrival.isDone, isFalse);

      expect(ServiceStatus.inService.isActive, isTrue);
      expect(ServiceStatus.inService.isDone, isFalse);

      expect(ServiceStatus.qualityCheck.isActive, isTrue);
      expect(ServiceStatus.qualityCheck.isDone, isFalse);

      expect(ServiceStatus.completed.isActive, isFalse);
      expect(ServiceStatus.completed.isDone, isTrue);
    });
  });

  group('Multi-Vehicle Tracking tests', () {
    final now = DateTime.now();

    final vehicleA = BookingVehicle(
      id: 'bv-001',
      bookingId: 'SRV-TEST',
      vehicleId: 'vhc-001',
      vehicleSnapshot: const VehicleSnapshot(
        plateNumber: 'B 1234 ABC',
        categoryId: 'motor',
        brandName: 'Honda',
        modelName: 'Vario 160',
      ),
      serviceTypeId: 'periodic_service',
      serviceSnapshot: const ServiceSnapshot(name: 'Servis Berkala', basePrice: 75000),
      selectedParts: const [],
      estimatedCost: 75000,
      estimatedDuration: 60,
      serviceStatus: ServiceStatus.completed,
      statusHistory: [
        StatusEvent(status: 'waiting_arrival', timestamp: now),
        StatusEvent(status: 'completed', timestamp: now),
      ],
    );

    final vehicleB = BookingVehicle(
      id: 'bv-002',
      bookingId: 'SRV-TEST',
      vehicleId: 'vhc-002',
      vehicleSnapshot: const VehicleSnapshot(
        plateNumber: 'B 5678 DEF',
        categoryId: 'mobil',
        brandName: 'Toyota',
        modelName: 'Avanza',
      ),
      serviceTypeId: 'oil_change',
      serviceSnapshot: const ServiceSnapshot(name: 'Ganti Oli', basePrice: 50000),
      selectedParts: const [],
      estimatedCost: 50000,
      estimatedDuration: 45,
      serviceStatus: ServiceStatus.inService,
      statusHistory: [
        StatusEvent(status: 'waiting_arrival', timestamp: now),
        StatusEvent(status: 'in_service', timestamp: now),
      ],
    );

    final booking = Booking(
      id: 'SRV-TEST',
      userId: 'usr-001',
      workshopId: 'ws-001',
      slotId: 'slot-001',
      workshopSnapshot: const WorkshopSnapshot(
        name: 'Bengkel Test',
        address: 'Jl. Test No. 1',
        phone: '08123456789',
      ),
      slotSnapshot: const SlotSnapshot(date: '2026-10-05', time: '09:00'),
      vehicles: [vehicleA, vehicleB],
      status: BookingStatus.inProgress,
      statusHistory: [StatusEvent(status: 'in_progress', timestamp: now)],
      totalEstimatedCost: 125000,
      totalEstimatedDuration: 105,
      createdAt: now,
      updatedAt: now,
    );

    test('Booking accurately reflects individual vehicle status differences', () {
      expect(booking.vehicleCount, 2);
      expect(booking.allVehiclesCompleted, isFalse);
      expect(booking.vehicles[0].serviceStatus, ServiceStatus.completed);
      expect(booking.vehicles[1].serviceStatus, ServiceStatus.inService);
    });

    test('allVehiclesCompleted becomes true when all vehicles reach completed status', () {
      final updatedBooking = Booking(
        id: booking.id,
        userId: booking.userId,
        workshopId: booking.workshopId,
        slotId: booking.slotId,
        workshopSnapshot: booking.workshopSnapshot,
        slotSnapshot: booking.slotSnapshot,
        vehicles: [
          vehicleA,
          vehicleB.copyWith(serviceStatus: ServiceStatus.completed),
        ],
        status: BookingStatus.completed,
        statusHistory: booking.statusHistory,
        totalEstimatedCost: booking.totalEstimatedCost,
        totalEstimatedDuration: booking.totalEstimatedDuration,
        createdAt: now,
        updatedAt: now,
      );

      expect(updatedBooking.allVehiclesCompleted, isTrue);
    });
  });

  group('WorkshopSlot capacity tests', () {
    test('WorkshopSlot correctly evaluates capacity for multi-vehicle batch', () {
      const slot = WorkshopSlot(
        id: 'slot-001',
        workshopId: 'ws-001',
        date: '2026-10-05',
        time: '09:00',
        capacity: 4,
        booked: 2,
      );

      expect(slot.available, 2);
      expect(slot.isBookable, isTrue);
      expect(slot.hasCapacityFor(1), isTrue);
      expect(slot.hasCapacityFor(2), isTrue);
      expect(slot.hasCapacityFor(3), isFalse); // exceeds remaining available capacity
    });

    test('Full WorkshopSlot rejects any capacity request', () {
      const fullSlot = WorkshopSlot(
        id: 'slot-002',
        workshopId: 'ws-001',
        date: '2026-10-05',
        time: '10:00',
        capacity: 4,
        booked: 4,
      );

      expect(fullSlot.available, 0);
      expect(fullSlot.isFull, isTrue);
      expect(fullSlot.hasCapacityFor(1), isFalse);
    });
  });
}
