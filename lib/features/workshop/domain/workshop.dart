// lib/features/workshop/domain/workshop.dart
import 'package:equatable/equatable.dart';

class OpenHour extends Equatable {
  const OpenHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  final int dayOfWeek; // 1=Monday … 7=Sunday
  final String openTime; // "08:00"
  final String closeTime; // "17:00"
  final bool isClosed;

  String get displayHours =>
      isClosed ? 'Tutup' : '$openTime – $closeTime';

  @override
  List<Object?> get props => [dayOfWeek];
}

class Workshop extends Equatable {
  const Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.photoUrls,
    required this.openHours,
    required this.serviceIds,
    required this.categories,
    this.distanceKm,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String district;
  final String city;
  final double latitude;
  final double longitude;
  final String phone;
  final double rating;
  final int reviewCount;
  final List<String> photoUrls;
  final List<OpenHour> openHours;
  final List<String> serviceIds;
  final List<String> categories; // ["motor"] | ["mobil"] | ["motor","mobil"]
  final double? distanceKm;
  final bool isActive;

  bool supportsCategory(String categoryId) => categories.contains(categoryId);
  bool supportsService(String serviceId) => serviceIds.contains(serviceId);

  String get distanceLabel {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String get ratingLabel => rating.toStringAsFixed(1);

  Workshop copyWith({double? distanceKm}) => Workshop(
        id: id,
        name: name,
        address: address,
        district: district,
        city: city,
        latitude: latitude,
        longitude: longitude,
        phone: phone,
        rating: rating,
        reviewCount: reviewCount,
        photoUrls: photoUrls,
        openHours: openHours,
        serviceIds: serviceIds,
        categories: categories,
        distanceKm: distanceKm ?? this.distanceKm,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [id];
}

enum SlotStatus { tersedia, hampirPenuh, penuh }

class WorkshopSlot extends Equatable {
  const WorkshopSlot({
    required this.id,
    required this.workshopId,
    required this.date,
    required this.time,
    required this.capacity,
    required this.booked,
  });

  final String id;
  final String workshopId;
  final String date; // "2026-10-05"
  final String time; // "09:00"
  final int capacity;
  final int booked;

  int get available => capacity - booked;

  SlotStatus get status {
    if (available == 0) return SlotStatus.penuh;
    if (available <= (capacity * 0.5).ceil()) return SlotStatus.hampirPenuh;
    return SlotStatus.tersedia;
  }

  bool get isBookable => status != SlotStatus.penuh;
  bool get isFull => !isBookable;
  bool hasCapacityFor(int vehicleCount) => available >= vehicleCount;


  String get statusLabel => switch (status) {
        SlotStatus.tersedia => 'Tersedia',
        SlotStatus.hampirPenuh => 'Hampir Penuh',
        SlotStatus.penuh => 'Penuh',
      };

  @override
  List<Object?> get props => [id];
}
