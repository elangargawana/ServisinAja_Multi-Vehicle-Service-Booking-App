// lib/shared/widgets/chips/status_badge.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/enums/booking_status.dart';
import 'package:servis_aja/features/booking/domain/enums/service_status.dart';

/// Displays a colored status badge for BookingStatus.
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return _BadgeChip(
      label: status.label,
      color: status.color,
      containerColor: status.containerColor,
    );
  }
}

/// Displays a colored status badge for ServiceStatus (per vehicle).
class ServiceStatusBadge extends StatelessWidget {
  const ServiceStatusBadge({super.key, required this.status});
  final ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    return _BadgeChip(
      label: status.shortLabel,
      color: status.color,
      containerColor: status.containerColor,
    );
  }
}

/// Internal chip implementation shared by both badge types.
class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.color,
    required this.containerColor,
  });

  final String label;
  final Color color;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
