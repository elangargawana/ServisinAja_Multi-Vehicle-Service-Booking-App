// lib/features/vehicles/domain/vehicle.dart
import 'package:equatable/equatable.dart';

class VehicleCategory extends Equatable {
  const VehicleCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id; // "motor" | "mobil"
  final String label;
  final String icon; // asset name

  bool get isMotor => id == 'motor';
  bool get isMobil => id == 'mobil';

  @override
  List<Object?> get props => [id];
}

class VehicleBrand extends Equatable {
  const VehicleBrand({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.categories,
  });

  final String id;
  final String name;
  final String logoUrl;
  final List<String> categories;

  bool supportsCategory(String categoryId) => categories.contains(categoryId);

  @override
  List<Object?> get props => [id];
}

class VehicleModel extends Equatable {
  const VehicleModel({
    required this.id,
    required this.brandId,
    required this.categoryId,
    required this.name,
    required this.yearStart,
    required this.yearEnd,
  });

  final String id;
  final String brandId;
  final String categoryId;
  final String name;
  final int yearStart;
  final int yearEnd;

  @override
  List<Object?> get props => [id];
}

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.userId,
    required this.plateNumber,
    required this.categoryId,
    required this.brandId,
    required this.modelId,
    required this.brandName,
    required this.modelName,
    this.alias,
    this.year,
    this.color,
    this.imageUrl,
    this.lastServiceDate,
    this.odometer,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String plateNumber;
  final String categoryId;
  final String brandId;
  final String modelId;

  /// Denormalized for display (avoids extra lookups in widgets)
  final String brandName;
  final String modelName;

  final String? alias;
  final int? year;
  final String? color;
  final String? imageUrl;
  final DateTime? lastServiceDate;
  final int? odometer;
  final DateTime createdAt;

  bool get isMotor => categoryId == 'motor';
  bool get isMobil => categoryId == 'mobil';

  /// Display name: alias if set, otherwise "Brand Model"
  String get displayName => alias ?? '$brandName $modelName';

  Vehicle copyWith({
    String? alias,
    String? plateNumber,
    int? year,
    String? color,
    String? imageUrl,
    DateTime? lastServiceDate,
    int? odometer,
  }) =>
      Vehicle(
        id: id,
        userId: userId,
        plateNumber: plateNumber ?? this.plateNumber,
        categoryId: categoryId,
        brandId: brandId,
        modelId: modelId,
        brandName: brandName,
        modelName: modelName,
        alias: alias ?? this.alias,
        year: year ?? this.year,
        color: color ?? this.color,
        imageUrl: imageUrl ?? this.imageUrl,
        lastServiceDate: lastServiceDate ?? this.lastServiceDate,
        odometer: odometer ?? this.odometer,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id];
}
