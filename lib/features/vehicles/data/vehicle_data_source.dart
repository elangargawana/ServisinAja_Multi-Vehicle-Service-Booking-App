// lib/features/vehicles/data/vehicle_data_source.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:servis_aja/core/constants/asset_constants.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';

/// Loads vehicle reference data and user garage from JSON assets.
class VehicleDataSource {
  List<Vehicle>? _inMemoryVehicles;
  bool _hasLoadedMock = false;

  Future<List<Vehicle>> fetchUserVehicles() async {
    if (!_hasLoadedMock) {
      final json = await rootBundle.loadString(AssetConstants.mockUserProfile);
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = data['vehicles'] as List<dynamic>;
      final mockList = list.map(_vehicleFromJson).toList();
      _inMemoryVehicles = [
        ...?_inMemoryVehicles,
        ...mockList,
      ];
      _hasLoadedMock = true;
    }
    return List.unmodifiable(_inMemoryVehicles!);
  }

  void addUserVehicle(Vehicle vehicle) {
    _inMemoryVehicles ??= [];
    _inMemoryVehicles!.insert(0, vehicle);
  }

  Future<List<VehicleBrand>> fetchBrands() async {
    final json = await rootBundle.loadString(AssetConstants.mockVehicleBrands);
    final list = jsonDecode(json) as List<dynamic>;
    return list.map(_brandFromJson).toList();
  }

  Future<List<VehicleModel>> fetchModels() async {
    final json = await rootBundle.loadString(AssetConstants.mockVehicleModels);
    final list = jsonDecode(json) as List<dynamic>;
    return list.map(_modelFromJson).toList();
  }

  // ── Mapping helpers ──────────────────────────────────────────────

  Vehicle _vehicleFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return Vehicle(
      id: m['id'] as String,
      userId: m['userId'] as String,
      plateNumber: m['plateNumber'] as String,
      categoryId: m['categoryId'] as String,
      brandId: m['brandId'] as String,
      modelId: m['modelId'] as String,
      brandName: m['brandName'] as String,
      modelName: m['modelName'] as String,
      alias: m['alias'] as String?,
      year: m['year'] as int?,
      color: m['color'] as String?,
      imageUrl: m['imageUrl'] as String?,
      lastServiceDate: m['lastServiceDate'] != null
          ? DateTime.tryParse(m['lastServiceDate'] as String)
          : null,
      odometer: m['odometer'] as int?,
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }

  VehicleBrand _brandFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return VehicleBrand(
      id: m['id'] as String,
      name: m['name'] as String,
      logoUrl: m['logoUrl'] as String,
      categories: List<String>.from(m['categories'] as List),
    );
  }

  VehicleModel _modelFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return VehicleModel(
      id: m['id'] as String,
      brandId: m['brandId'] as String,
      categoryId: m['categoryId'] as String,
      name: m['name'] as String,
      yearStart: m['yearStart'] as int,
      yearEnd: m['yearEnd'] as int,
    );
  }
}
