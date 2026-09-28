// lib/core/constants/route_constants.dart

/// Named route paths and names for go_router.
/// Always use these constants — never hardcode route strings.
abstract final class RouteConstants {
  // ── Route Paths ───────────────────────────────────────────────────
  static const String home = '/home';
  static const String workshopList = '/booking/workshop';
  static const String workshopDetail = '/booking/workshop/:workshopId';
  static const String schedule = '/booking/schedule';
  static const String garage = '/booking/garage';
  static const String selectVehicle = '/booking/select-vehicle';
  static const String addVehicle = '/booking/add-vehicle';
  static const String vehicleConfig = '/booking/configure/:vehicleId';
  static const String bookingReview = '/booking/review';
  static const String bookingSuccess = '/booking/success';
  static const String trackingDetail = '/tracking/:bookingId';
  static const String bookingHistory = '/history';

  // ── Named Routes (for context.goNamed()) ─────────────────────────
  static const String nameHome = 'home';
  static const String nameWorkshopList = 'workshopList';
  static const String nameWorkshopDetail = 'workshopDetail';
  static const String nameSchedule = 'schedule';
  static const String nameGarage = 'garage';
  static const String nameSelectVehicle = 'selectVehicle';
  static const String nameAddVehicle = 'addVehicle';
  static const String nameVehicleConfig = 'vehicleConfig';
  static const String nameBookingReview = 'bookingReview';
  static const String nameBookingSuccess = 'bookingSuccess';
  static const String nameTrackingDetail = 'trackingDetail';
  static const String nameBookingHistory = 'bookingHistory';

  // ── Path Parameters ───────────────────────────────────────────────
  static const String paramWorkshopId = 'workshopId';
  static const String paramVehicleId = 'vehicleId';
  static const String paramBookingId = 'bookingId';
}
