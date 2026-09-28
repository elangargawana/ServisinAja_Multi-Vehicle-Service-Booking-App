// lib/features/booking/domain/spare_part.dart
import 'package:equatable/equatable.dart';

class SparePart extends Equatable {
  const SparePart({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.compatibleVehicleCategories,
    required this.compatibleServiceIds,
    required this.unit,
    required this.isRecommended,
    required this.sortOrder,
    this.description,
    this.priceMotor,
    this.priceMobil,
  });

  final String id;
  final String name;
  final String brand;
  final String? description;
  final String category; // "oli" | "filter" | "busi" | "kampas" | "aki" | "lainnya"
  final List<String> compatibleVehicleCategories;
  final List<String> compatibleServiceIds;
  final int? priceMotor;
  final int? priceMobil;
  final String unit;
  final bool isRecommended;
  final int sortOrder;

  /// Returns price for the given vehicle category, or null if not compatible.
  int? priceFor(String categoryId) {
    if (categoryId == 'motor') return priceMotor;
    return priceMobil;
  }

  bool isCompatibleWith({
    required String vehicleCategoryId,
    String? serviceId,
  }) {
    final catOk = compatibleVehicleCategories.contains(vehicleCategoryId);
    if (!catOk) return false;
    if (serviceId != null && compatibleServiceIds.isNotEmpty) {
      return compatibleServiceIds.contains(serviceId);
    }
    return true;
  }

  @override
  List<Object?> get props => [id];
}

/// Value object representing a selected spare part in a booking.
/// Stores a price snapshot — price is frozen at selection time.
class SparePartSelection extends Equatable {
  const SparePartSelection({
    required this.partId,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.unitPrice,
  });

  final String partId;
  final String name;
  final String brand;
  final int quantity;
  final int unitPrice; // snapshot price at selection time

  int get subtotal => quantity * unitPrice;

  SparePartSelection copyWith({int? quantity}) => SparePartSelection(
        partId: partId,
        name: name,
        brand: brand,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
      );

  @override
  List<Object?> get props => [partId, quantity, unitPrice];
}
