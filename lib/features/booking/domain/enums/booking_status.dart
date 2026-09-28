// lib/features/booking/domain/enums/booking_status.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/theme/app_colors.dart';

enum BookingStatus {
  draft,
  pendingConfirmation,
  confirmed,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        draft => 'Draft',
        pendingConfirmation => 'Menunggu Konfirmasi',
        confirmed => 'Dikonfirmasi',
        inProgress => 'Sedang Dikerjakan',
        completed => 'Selesai',
        cancelled => 'Dibatalkan',
      };

  Color get color => switch (this) {
        draft => AppColors.neutral500,
        pendingConfirmation => AppColors.warning,
        confirmed => AppColors.info,
        inProgress => AppColors.primary,
        completed => AppColors.success,
        cancelled => AppColors.error,
      };

  Color get containerColor => switch (this) {
        draft => AppColors.neutral100,
        pendingConfirmation => AppColors.warningContainer,
        confirmed => AppColors.infoContainer,
        inProgress => AppColors.primaryContainer,
        completed => AppColors.successContainer,
        cancelled => AppColors.errorContainer,
      };

  bool get isActive => this == inProgress || this == confirmed;
  bool get isDone => this == completed || this == cancelled;

  static BookingStatus fromString(String value) => switch (value) {
        'draft' => draft,
        'pending_confirmation' => pendingConfirmation,
        'confirmed' => confirmed,
        'in_progress' => inProgress,
        'completed' => completed,
        'cancelled' => cancelled,
        _ => draft,
      };
}
