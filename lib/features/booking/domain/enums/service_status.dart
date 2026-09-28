// lib/features/booking/domain/enums/service_status.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/theme/app_colors.dart';

enum ServiceStatus {
  waitingArrival,
  arrived,
  beingInspected,
  inService,
  waitingParts,
  qualityCheck,
  completed;

  String get label => switch (this) {
        waitingArrival => 'Menunggu Kedatangan',
        arrived => 'Kendaraan Tiba',
        beingInspected => 'Sedang Diperiksa',
        inService => 'Sedang Dikerjakan',
        waitingParts => 'Menunggu Spare Part',
        qualityCheck => 'Pemeriksaan Akhir',
        completed => 'Selesai',
      };

  String get shortLabel => switch (this) {
        waitingArrival => 'Menunggu',
        arrived => 'Tiba',
        beingInspected => 'Diperiksa',
        inService => 'Dikerjakan',
        waitingParts => 'Nunggu Part',
        qualityCheck => 'QC',
        completed => 'Selesai',
      };

  Color get color => switch (this) {
        waitingArrival => AppColors.neutral400,
        arrived => AppColors.info,
        beingInspected => AppColors.warning,
        inService => AppColors.primary,
        waitingParts => AppColors.warningDark,
        qualityCheck => AppColors.secondary,
        completed => AppColors.success,
      };

  Color get containerColor => switch (this) {
        waitingArrival => AppColors.neutral100,
        arrived => AppColors.infoContainer,
        beingInspected => AppColors.warningContainer,
        inService => AppColors.primaryContainer,
        waitingParts => AppColors.warningContainer,
        qualityCheck => AppColors.secondaryContainer,
        completed => AppColors.successContainer,
      };

  bool get isActive => this != waitingArrival && this != completed;
  bool get isDone => this == completed;

  /// Step index for timeline display (0-based).
  int get timelineStep => switch (this) {
        waitingArrival => 0,
        arrived => 1,
        beingInspected => 1,
        inService => 2,
        waitingParts => 2,
        qualityCheck => 3,
        completed => 4,
      };

  static ServiceStatus fromString(String value) => switch (value) {
        'waiting_arrival' => waitingArrival,
        'arrived' => arrived,
        'being_inspected' => beingInspected,
        'in_service' => inService,
        'waiting_parts' => waitingParts,
        'quality_check' => qualityCheck,
        'completed' => completed,
        _ => waitingArrival,
      };
}
