// lib/features/workshop/data/workshop_data_source.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:servis_aja/core/constants/asset_constants.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';

/// Loads workshop and slot data from JSON assets.
class WorkshopDataSource {
  Future<List<Workshop>> fetchWorkshops() async {
    final json = await rootBundle.loadString(AssetConstants.mockWorkshops);
    final list = jsonDecode(json) as List<dynamic>;
    return list.map(_workshopFromJson).toList();
  }

  Future<List<WorkshopSlot>> fetchSlotsForWorkshop(
    String workshopId,
    String date,
  ) async {
    final json = await rootBundle.loadString(AssetConstants.mockBookings);
    final data = jsonDecode(json) as Map<String, dynamic>;
    final slots = data['slots'] as List<dynamic>;
    final existing = slots
        .map(_slotFromJson)
        .where((s) => s.workshopId == workshopId && s.date == date)
        .toList();
    if (existing.isNotEmpty) {
      return existing;
    }

    return _generateDefaultSlots(workshopId, date);
  }

  List<WorkshopSlot> _generateDefaultSlots(String workshopId, String date) {
    final dt = DateTime.tryParse(date);
    final weekday = dt?.weekday ?? 1;

    // Hari Minggu: bengkel ws-005 (Bekasi Timur) buka setengah hari, bengkel lain tutup
    if (weekday == DateTime.sunday && workshopId != 'ws-005') {
      return [];
    }

    final times = (weekday == DateTime.saturday || weekday == DateTime.sunday)
        ? const ['08:00', '09:00', '10:00', '11:00', '13:00']
        : const [
            '08:00',
            '09:00',
            '10:00',
            '11:00',
            '13:00',
            '14:00',
            '15:00',
            '16:00'
          ];

    return times.map((time) {
      final seed = (workshopId.hashCode ^ date.hashCode ^ time.hashCode).abs();
      const capacity = 4;
      final booked = seed % 3; // 0, 1, atau 2 terisi -> selalu tersisa 2-4 slot
      return WorkshopSlot(
        id: 'slot-$workshopId-$date-${time.replaceAll(':', '')}',
        workshopId: workshopId,
        date: date,
        time: time,
        capacity: capacity,
        booked: booked,
      );
    }).toList();
  }

  // ── Mapping helpers ──────────────────────────────────────────────

  Workshop _workshopFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    final hoursRaw = m['openHours'] as List<dynamic>;
    return Workshop(
      id: m['id'] as String,
      name: m['name'] as String,
      address: m['address'] as String,
      district: m['district'] as String,
      city: m['city'] as String,
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      phone: m['phone'] as String,
      rating: (m['rating'] as num).toDouble(),
      reviewCount: m['reviewCount'] as int,
      photoUrls: List<String>.from(m['photoUrls'] as List),
      openHours: hoursRaw.map(_openHourFromJson).toList(),
      serviceIds: List<String>.from(m['services'] as List),
      categories: List<String>.from(m['categories'] as List),
      isActive: m['isActive'] as bool? ?? true,
    );
  }

  OpenHour _openHourFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return OpenHour(
      dayOfWeek: m['dayOfWeek'] as int,
      openTime: m['openTime'] as String,
      closeTime: m['closeTime'] as String,
      isClosed: m['isClosed'] as bool,
    );
  }

  WorkshopSlot _slotFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return WorkshopSlot(
      id: m['id'] as String,
      workshopId: m['workshopId'] as String,
      date: m['date'] as String,
      time: m['time'] as String,
      capacity: m['capacity'] as int,
      booked: m['booked'] as int,
    );
  }
}
