// lib/features/vehicles/presentation/providers/vehicle_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';

// ── Vehicle Filter ────────────────────────────────────────────────────────────

enum VehicleCategoryFilter { all, motor, mobil }

extension VehicleCategoryFilterX on VehicleCategoryFilter {
  String get label => switch (this) {
        VehicleCategoryFilter.all => 'Semua',
        VehicleCategoryFilter.motor => 'Motor',
        VehicleCategoryFilter.mobil => 'Mobil',
      };
}

/// Active filter on the vehicle selection screen.
final vehicleCategoryFilterProvider =
    StateProvider<VehicleCategoryFilter>((ref) => VehicleCategoryFilter.all);

/// Vehicles filtered by the active category filter.
final filteredVehiclesProvider = Provider<AsyncValue<List<Vehicle>>>((ref) {
  final asyncVehicles = ref.watch(userVehiclesProvider);
  final filter = ref.watch(vehicleCategoryFilterProvider);

  return asyncVehicles.whenData((vehicles) {
    if (filter == VehicleCategoryFilter.all) return vehicles;
    return vehicles
        .where((v) => v.categoryId == filter.name)
        .toList();
  });
});

/// Form state for the Add Vehicle flow.
class AddVehicleFormState {
  const AddVehicleFormState({
    this.alias = '',
    this.plateNumber = '',
    this.selectedCategoryId,
    this.selectedBrandId,
    this.selectedModelId,
    this.selectedYear,
    this.color = '',
    this.isSubmitting = false,
  });

  final String alias;
  final String plateNumber;
  final String? selectedCategoryId;
  final String? selectedBrandId;
  final String? selectedModelId;
  final int? selectedYear;
  final String color;
  final bool isSubmitting;

  bool get isValid =>
      plateNumber.trim().isNotEmpty &&
      selectedCategoryId != null &&
      selectedBrandId != null &&
      selectedModelId != null;

  // Plate format: 1-2 letters + space + 1-4 digits + space + 1-3 letters
  bool get isPlateValid {
    final trimmed = plateNumber.trim().toUpperCase();
    if (trimmed.isEmpty) return false;
    final pattern = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');
    return pattern.hasMatch(trimmed);
  }

  String? get plateError {
    if (plateNumber.isEmpty) return null; // no error until user types
    if (!isPlateValid) return 'Format plat tidak valid (contoh: B 1234 SKY)';
    return null;
  }

  AddVehicleFormState copyWith({
    String? alias,
    String? plateNumber,
    String? selectedCategoryId,
    String? selectedBrandId,
    String? selectedModelId,
    int? selectedYear,
    String? color,
    bool? isSubmitting,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearYear = false,
  }) =>
      AddVehicleFormState(
        alias: alias ?? this.alias,
        plateNumber: plateNumber ?? this.plateNumber,
        selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
        selectedBrandId: clearBrand ? null : (selectedBrandId ?? this.selectedBrandId),
        selectedModelId: clearModel ? null : (selectedModelId ?? this.selectedModelId),
        selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
        color: color ?? this.color,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

/// Form state provider — autoDispose so it resets when user leaves the screen.
final addVehicleFormProvider =
    StateNotifierProvider.autoDispose<AddVehicleFormNotifier, AddVehicleFormState>(
  (ref) => AddVehicleFormNotifier(),
);

class AddVehicleFormNotifier extends StateNotifier<AddVehicleFormState> {
  AddVehicleFormNotifier() : super(const AddVehicleFormState());

  void setAlias(String value) => state = state.copyWith(alias: value);
  void setPlateNumber(String value) =>
      state = state.copyWith(plateNumber: value);
  void setColor(String value) => state = state.copyWith(color: value);

  void setCategory(String categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearBrand: true,
      clearModel: true,
      clearYear: true,
    );
  }

  void setBrand(String brandId) {
    state = state.copyWith(
      selectedBrandId: brandId,
      clearModel: true,
      clearYear: true,
    );
  }

  void setModel(String modelId) {
    state = state.copyWith(
      selectedModelId: modelId,
      clearYear: true,
    );
  }

  void setYear(int year) => state = state.copyWith(selectedYear: year);

  void setSubmitting(bool value) => state = state.copyWith(isSubmitting: value);
}
