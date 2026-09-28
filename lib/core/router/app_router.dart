// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/presentation/screens/booking_review_screen.dart';
import 'package:servis_aja/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:servis_aja/features/booking/presentation/screens/garage_screen.dart';
import 'package:servis_aja/features/booking/presentation/screens/schedule_screen.dart';
import 'package:servis_aja/features/booking/presentation/screens/vehicle_config_screen.dart';
import 'package:servis_aja/features/home/presentation/screens/home_screen.dart';
import 'package:servis_aja/features/tracking/presentation/screens/booking_history_screen.dart';
import 'package:servis_aja/features/tracking/presentation/screens/tracking_detail_screen.dart';
import 'package:servis_aja/features/vehicles/presentation/screens/add_vehicle_screen.dart';
import 'package:servis_aja/features/vehicles/presentation/screens/vehicle_selection_screen.dart';
import 'package:servis_aja/features/workshop/presentation/screens/workshop_detail_screen.dart';
import 'package:servis_aja/features/workshop/presentation/screens/workshop_list_screen.dart';

/// Central GoRouter configuration.
/// Routes are ordered by booking flow step for easy navigation.
final appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  debugLogDiagnostics: true,
  routes: [
    // ── Home ─────────────────────────────────────────────────────────
    GoRoute(
      path: RouteConstants.home,
      name: RouteConstants.nameHome,
      builder: (_, __) => const HomeScreen(),
    ),

    // ── Booking Flow ──────────────────────────────────────────────────
    // Step 0a: Multi-vehicle orchestrator (garage)
    GoRoute(
      path: RouteConstants.garage,
      name: RouteConstants.nameGarage,
      builder: (_, __) => const GarageScreen(),
    ),

    // Step 0b: Vehicle picker (from garage FAB)
    GoRoute(
      path: RouteConstants.selectVehicle,
      name: RouteConstants.nameSelectVehicle,
      builder: (_, __) => const VehicleSelectionScreen(),
    ),

    // Step 0c: Add new vehicle
    GoRoute(
      path: RouteConstants.addVehicle,
      name: RouteConstants.nameAddVehicle,
      builder: (_, __) => const AddVehicleScreen(),
    ),

    // Step 1: Configure each vehicle
    GoRoute(
      path: RouteConstants.vehicleConfig,
      name: RouteConstants.nameVehicleConfig,
      builder: (_, state) {
        final vehicleId =
            state.pathParameters[RouteConstants.paramVehicleId]!;
        return VehicleConfigScreen(vehicleId: vehicleId);
      },
    ),

    // Step 2: Workshop list + detail
    GoRoute(
      path: RouteConstants.workshopList,
      name: RouteConstants.nameWorkshopList,
      builder: (_, __) => const WorkshopListScreen(),
      routes: [
        GoRoute(
          path: ':${RouteConstants.paramWorkshopId}',
          name: RouteConstants.nameWorkshopDetail,
          builder: (_, state) {
            final id = state.pathParameters[RouteConstants.paramWorkshopId]!;
            return WorkshopDetailScreen(workshopId: id);
          },
        ),
      ],
    ),

    // Step 3: Schedule selection
    GoRoute(
      path: RouteConstants.schedule,
      name: RouteConstants.nameSchedule,
      builder: (_, __) => const ScheduleScreen(),
    ),

    // Step 4: Booking review
    GoRoute(
      path: RouteConstants.bookingReview,
      name: RouteConstants.nameBookingReview,
      builder: (_, __) => const BookingReviewScreen(),
    ),

    // Step 5: Booking success
    GoRoute(
      path: RouteConstants.bookingSuccess,
      name: RouteConstants.nameBookingSuccess,
      builder: (_, state) {
        if (state.extra is Booking) {
          return BookingSuccessScreen(booking: state.extra as Booking);
        }
        if (state.extra is BookingSession) {
          return BookingSuccessScreen(session: state.extra as BookingSession);
        }
        return const BookingSuccessScreen();
      },
    ),

    // ── Tracking ──────────────────────────────────────────────────────
    GoRoute(
      path: RouteConstants.trackingDetail,
      name: RouteConstants.nameTrackingDetail,
      builder: (_, state) {
        final bookingId =
            state.pathParameters[RouteConstants.paramBookingId]!;
        return TrackingDetailScreen(bookingId: bookingId);
      },
    ),

    // ── History ───────────────────────────────────────────────────────
    GoRoute(
      path: RouteConstants.bookingHistory,
      name: RouteConstants.nameBookingHistory,
      builder: (_, __) => const BookingHistoryScreen(),
    ),
  ],
  errorBuilder: (_, state) => _RouteErrorScreen(error: state.error),
);



class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Text('Error: ${error?.toString() ?? 'Unknown route'}'),
      ),
    );
  }
}
