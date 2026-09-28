// lib/shared/providers/shared_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/core/utils/mock_delay.dart';
import 'package:servis_aja/features/booking/data/booking_data_source.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/service_type.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';
import 'package:servis_aja/features/vehicles/data/vehicle_data_source.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/workshop/data/workshop_data_source.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

// ── Data Source Providers (singletons) ───────────────────────────────────────

final vehicleDataSourceProvider = Provider<VehicleDataSource>(
  (_) => VehicleDataSource(),
);

final workshopDataSourceProvider = Provider<WorkshopDataSource>(
  (_) => WorkshopDataSource(),
);

final bookingDataSourceProvider = Provider<BookingDataSource>(
  (_) => BookingDataSource(),
);

// ── Reference Data (loaded once, cached) ─────────────────────────────────────

/// All vehicles in the user's garage.
final userVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  await MockDelay.fast();
  return ref.read(vehicleDataSourceProvider).fetchUserVehicles();
});

/// All vehicle brands.
final vehicleBrandsProvider = FutureProvider<List<VehicleBrand>>((ref) async {
  return ref.read(vehicleDataSourceProvider).fetchBrands();
});

/// All vehicle models.
final vehicleModelsProvider = FutureProvider<List<VehicleModel>>((ref) async {
  return ref.read(vehicleDataSourceProvider).fetchModels();
});

/// All workshops.
final workshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  await MockDelay.simulate();
  return ref.read(workshopDataSourceProvider).fetchWorkshops();
});

/// All service types.
final serviceTypesProvider = FutureProvider<List<ServiceType>>((ref) async {
  return ref.read(bookingDataSourceProvider).fetchServiceTypes();
});

/// Service types filtered for a specific vehicle category.
final serviceTypesForCategoryProvider =
    FutureProvider.family<List<ServiceType>, String>((ref, categoryId) async {
  final all = await ref.watch(serviceTypesProvider.future);
  return all.where((s) => s.supportsCategory(categoryId)).toList();
});

/// All spare parts.
final sparePartsProvider = FutureProvider<List<SparePart>>((ref) async {
  return ref.read(bookingDataSourceProvider).fetchSpareParts();
});

/// Spare parts filtered for a specific vehicle category and service.
final sparePartsForServiceProvider = FutureProvider.family<List<SparePart>,
    ({String categoryId, String serviceId})>((ref, args) async {
  final all = await ref.watch(sparePartsProvider.future);
  return all
      .where(
        (p) => p.isCompatibleWith(
          vehicleCategoryId: args.categoryId,
          serviceId: args.serviceId,
        ),
      )
      .toList();
});

/// Workshop slots for a specific workshop + date.
final workshopSlotsProvider = FutureProvider.family<List<WorkshopSlot>,
    ({String workshopId, String date})>((ref, args) async {
  await MockDelay.fast();
  return ref
      .read(workshopDataSourceProvider)
      .fetchSlotsForWorkshop(args.workshopId, args.date);
});

/// All bookings for the current user.
final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  await MockDelay.simulate();
  return ref.read(bookingDataSourceProvider).fetchBookings('usr-001');
});

/// Active (non-completed) bookings for the current user.
final activeBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final all = await ref.watch(userBookingsProvider.future);
  return all.where((b) => !b.status.isDone).toList();
});

/// Completed/cancelled bookings (booking history).
final bookingHistoryProvider = FutureProvider<List<Booking>>((ref) async {
  final all = await ref.watch(userBookingsProvider.future);
  return all.where((b) => b.status.isDone).toList();
});

/// A single booking by ID (for tracking/detail screen).
final bookingDetailProvider =
    FutureProvider.family<Booking?, String>((ref, bookingId) async {
  await MockDelay.fast();
  final all = await ref.watch(userBookingsProvider.future);
  try {
    return all.firstWhere((b) => b.id == bookingId);
  } catch (_) {
    return null;
  }
});
