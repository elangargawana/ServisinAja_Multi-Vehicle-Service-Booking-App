// lib/shared/widgets/cards/booking_cost_bar.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/extensions/int_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';

/// Persistent floating summary bar shown at the bottom of booking flow screens.
/// Displays total estimated cost and duration across all configured vehicles.
class BookingCostBar extends StatelessWidget {
  const BookingCostBar({
    super.key,
    required this.totalCost,
    required this.totalDurationMinutes,
    required this.vehicleCount,
  });

  final int totalCost;
  final int totalDurationMinutes;
  final int vehicleCount;

  @override
  Widget build(BuildContext context) {
    if (vehicleCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation3,
      ),
      child: Row(
        children: [
          // Cost
          Expanded(
            child: _SummaryItem(
              icon: Icons.payments_rounded,
              label: 'Est. Biaya',
              value: totalCost > 0 ? totalCost.toCurrency() : 'Belum dipilih',
              valueColor: totalCost > 0
                  ? AppColors.warning
                  : AppColors.neutral400,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.neutral700,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          // Duration
          Expanded(
            child: _SummaryItem(
              icon: Icons.timer_rounded,
              label: 'Est. Durasi',
              value: totalDurationMinutes > 0
                  ? totalDurationMinutes.toDurationLabel()
                  : 'Belum dipilih',
              valueColor: totalDurationMinutes > 0
                  ? AppColors.primaryLight
                  : AppColors.neutral400,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.neutral700,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          // Vehicle count
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$vehicleCount',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                'Kendaraan',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.neutral500),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  color: valueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
