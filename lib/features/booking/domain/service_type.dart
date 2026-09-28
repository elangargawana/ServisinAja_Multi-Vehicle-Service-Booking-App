// lib/features/booking/domain/service_type.dart
import 'package:equatable/equatable.dart';

class ServiceType extends Equatable {
  const ServiceType({
    required this.id,
    required this.name,
    required this.description,
    required this.compatibleCategories,
    required this.estimatedDurationMotor,
    this.basePriceMotor,
    this.basePriceMobil,
    this.estimatedDurationMobil,
    required this.iconName,
    required this.colorHex,
    required this.recommendedSparePartIds,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String description;
  final List<String> compatibleCategories;
  final int? basePriceMotor;
  final int? basePriceMobil;
  final int estimatedDurationMotor;
  final int? estimatedDurationMobil;
  final String iconName;
  final String colorHex;
  final List<String> recommendedSparePartIds;
  final int sortOrder;

  bool supportsCategory(String categoryId) =>
      compatibleCategories.contains(categoryId);

  int basePriceFor(String categoryId) {
    if (categoryId == 'motor') return basePriceMotor ?? 0;
    return basePriceMobil ?? 0;
  }

  int durationFor(String categoryId) {
    if (categoryId == 'motor') return estimatedDurationMotor;
    return estimatedDurationMobil ?? estimatedDurationMotor;
  }

  @override
  List<Object?> get props => [id];
}
