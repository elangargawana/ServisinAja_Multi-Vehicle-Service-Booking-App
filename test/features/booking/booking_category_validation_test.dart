import 'package:flutter_test/flutter_test.dart';
import 'package:servis_aja/core/errors/app_exception.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

void main() {
  group('BookingSession Vehicle & Workshop Category Compatibility Tests', () {
    late BookingSessionNotifier notifier;

    final carVehicle = Vehicle(
      id: 'v_car',
      userId: 'u_1',
      brandId: 'b_toyota',
      modelId: 'm_avanza',
      brandName: 'Toyota',
      modelName: 'Avanza',
      plateNumber: 'B 1234 CD',
      categoryId: 'mobil',
      year: 2020,
      createdAt: DateTime.now(),
    );

    final motorVehicle = Vehicle(
      id: 'v_motor',
      userId: 'u_1',
      brandId: 'b_honda',
      modelId: 'm_vario',
      brandName: 'Honda',
      modelName: 'Vario 150',
      plateNumber: 'B 5678 EF',
      categoryId: 'motor',
      year: 2021,
      createdAt: DateTime.now(),
    );

    final motorOnlyWorkshop = Workshop(
      id: 'w_motor',
      name: 'Bengkel Motor Sejahtera',
      address: 'Jl. Merdeka No. 1',
      district: 'Gambir',
      city: 'Jakarta Pusat',
      latitude: -6.175,
      longitude: 106.827,
      phone: '081234567890',
      rating: 4.8,
      reviewCount: 50,
      photoUrls: const [],
      openHours: const [],
      serviceIds: const ['srv_1'],
      categories: const ['motor'],
    );

    final carOnlyWorkshop = Workshop(
      id: 'w_car',
      name: 'Bengkel Mobil Maju Jaya',
      address: 'Jl. Thamrin No. 2',
      district: 'Menteng',
      city: 'Jakarta Pusat',
      latitude: -6.185,
      longitude: 106.825,
      phone: '081234567891',
      rating: 4.7,
      reviewCount: 40,
      photoUrls: const [],
      openHours: const [],
      serviceIds: const ['srv_1'],
      categories: const ['mobil'],
    );

    final dualWorkshop = Workshop(
      id: 'w_dual',
      name: 'Bengkel Servis Komplit',
      address: 'Jl. Sudirman No. 3',
      district: 'Setiabudi',
      city: 'Jakarta Selatan',
      latitude: -6.200,
      longitude: 106.820,
      phone: '081234567892',
      rating: 4.9,
      reviewCount: 100,
      photoUrls: const [],
      openHours: const [],
      serviceIds: const ['srv_1'],
      categories: const ['motor', 'mobil'],
    );

    setUp(() {
      notifier = BookingSessionNotifier();
    });

    test('Selecting motor-only workshop throws if car is already in session', () {
      notifier.addVehicle(carVehicle);
      expect(
        () => notifier.setWorkshop(motorOnlyWorkshop),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('Selecting car-only workshop throws if motor is already in session', () {
      notifier.addVehicle(motorVehicle);
      expect(
        () => notifier.setWorkshop(carOnlyWorkshop),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('Selecting dual workshop succeeds with both motor and car', () {
      notifier.addVehicle(motorVehicle);
      notifier.addVehicle(carVehicle);
      notifier.setWorkshop(dualWorkshop);
      expect(notifier.state.selectedWorkshop?.id, equals('w_dual'));
      expect(notifier.state.vehicleConfigs.length, equals(2));
    });

    test('Adding car throws when workshop already selected is motor-only', () {
      notifier.setWorkshop(motorOnlyWorkshop);
      expect(
        () => notifier.addVehicle(carVehicle),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('Adding motor throws when workshop already selected is car-only', () {
      notifier.setWorkshop(carOnlyWorkshop);
      expect(
        () => notifier.addVehicle(motorVehicle),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('Adding motor and car succeeds when workshop is dual', () {
      notifier.setWorkshop(dualWorkshop);
      notifier.addVehicle(motorVehicle);
      notifier.addVehicle(carVehicle);
      expect(notifier.state.vehicleConfigs.length, equals(2));
    });
  });
}
