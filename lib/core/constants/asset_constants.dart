// lib/core/constants/asset_constants.dart

/// Centralized asset path constants.
/// All asset references must go through this class — no string literals in widgets.
abstract final class AssetConstants {
  // ── Base paths ────────────────────────────────────────────────────
  static const String _images = 'assets/images';
  static const String _illustrations = 'assets/images/illustrations';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';
  static const String _mockData = 'assets/mock_data';

  // ── Header Background ──────────────────────────────────────────────
  static const String workshopHeaderBg = '$_images/workshop_header_bg.jpg';
  static const String workshopHeaderNetworkUrl =
      'https://images.unsplash.com/photo-1615906655593-ad0386982a0f?w=1200&auto=format&fit=crop&q=80';

  // ── Illustrations ─────────────────────────────────────────────────
  static const String emptyGarage = '$_illustrations/empty_garage.svg';
  static const String emptySearch = '$_illustrations/empty_search.svg';
  static const String emptyHistory = '$_illustrations/empty_history.svg';
  static const String errorNetwork = '$_illustrations/error_network.svg';
  static const String errorGeneral = '$_illustrations/error_general.svg';
  static const String bookingSuccessIllustration =
      '$_illustrations/booking_success.svg';

  // ── Vehicle Icons ─────────────────────────────────────────────────
  static const String iconMotor = '$_icons/ic_motor.svg';
  static const String iconMobil = '$_icons/ic_mobil.svg';

  // ── Service Icons ─────────────────────────────────────────────────
  static const String iconServicePeriodic =
      '$_icons/ic_service_periodic.svg';
  static const String iconServiceTuneUp = '$_icons/ic_service_tuneup.svg';
  static const String iconServiceOil = '$_icons/ic_service_oil.svg';
  static const String iconServiceBrake = '$_icons/ic_service_brake.svg';
  static const String iconServiceOverhaul =
      '$_icons/ic_service_overhaul.svg';
  static const String iconServiceOther = '$_icons/ic_service_other.svg';

  // ── Animations ────────────────────────────────────────────────────
  static const String bookingSuccessAnimation =
      '$_animations/booking_success.json';

  // ── Mock Data ─────────────────────────────────────────────────────
  static const String mockVehicleCategories =
      '$_mockData/vehicle_categories.json';
  static const String mockVehicleBrands = '$_mockData/vehicle_brands.json';
  static const String mockVehicleModels = '$_mockData/vehicle_models.json';
  static const String mockServiceTypes = '$_mockData/service_types.json';
  static const String mockSpareParts = '$_mockData/spare_parts.json';
  static const String mockWorkshops = '$_mockData/workshops.json';
  static const String mockWorkshopSlots = '$_mockData/workshop_slots.json';
  static const String mockUserProfile = '$_mockData/user_profile.json';
  static const String mockBookings = '$_mockData/bookings.json';
}
