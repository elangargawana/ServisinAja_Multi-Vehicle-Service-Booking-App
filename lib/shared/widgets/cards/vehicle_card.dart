// lib/shared/widgets/cards/vehicle_card.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/extensions/datetime_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';

/// Full vehicle card for list views (selection, garage).
/// [isSelected] — shows highlighted border + check icon.
/// [isDisabled] — dims the card (e.g., already in booking).
/// [trailing] — optional right-side widget (for garage management).
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.trailing,
    this.showLastService = true,
  });

  final Vehicle vehicle;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDisabled;
  final Widget? trailing;
  final bool showLastService;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? AppColors.primary : AppColors.borderSubtle;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isDisabled
            ? AppColors.neutral50
            : isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.3)
                : AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isSelected ? AppShadows.elevation2 : AppShadows.elevation1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: AppRadius.cardRadius,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // ── Vehicle Icon ──────────────────────────────────
                _VehicleIcon(vehicle: vehicle, isSelected: isSelected),
                const SizedBox(width: AppSpacing.md),

                // ── Vehicle Info ──────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vehicle.displayName,
                              style: AppTypography.titleMedium.copyWith(
                                color: isDisabled
                                    ? AppColors.textDisabled
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Category chip
                          _CategoryChip(
                            label: vehicle.isMotor ? 'Motor' : 'Mobil',
                            isMotor: vehicle.isMotor,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      // Plate + year
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r4),
                              border: Border.all(
                                  color: AppColors.borderDefault),
                            ),
                            child: Text(
                              vehicle.plateNumber,
                              style: AppTypography.monoMedium.copyWith(
                                fontSize: 11,
                                color: isDisabled
                                    ? AppColors.textDisabled
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (vehicle.year != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${vehicle.year}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDisabled
                                    ? AppColors.textDisabled
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Last service date
                      if (showLastService &&
                          vehicle.lastServiceDate != null) ...[
                        const SizedBox(height: AppSpacing.xs2),
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 12,
                              color: isDisabled
                                  ? AppColors.textDisabled
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSpacing.xs2),
                            Text(
                              'Servis: ${vehicle.lastServiceDate!.toShortDate()}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDisabled
                                    ? AppColors.textDisabled
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Trailing (check / custom) ─────────────────────
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ] else if (isSelected) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.onPrimary,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Vehicle Icon ─────────────────────────────────────────────────────────────

class _VehicleIcon extends StatelessWidget {
  const _VehicleIcon({required this.vehicle, required this.isSelected});
  final Vehicle vehicle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Icon(
        vehicle.isMotor
            ? Icons.two_wheeler_rounded
            : Icons.directions_car_rounded,
        color: isSelected ? AppColors.primary : AppColors.primaryDark,
        size: 26,
      ),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isMotor});
  final String label;
  final bool isMotor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: isMotor ? AppColors.infoContainer : AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: isMotor ? AppColors.info : AppColors.successDark,
        ),
      ),
    );
  }
}

/// Compact read-only vehicle card for summary/review screens.
class VehicleCardCompact extends StatelessWidget {
  const VehicleCardCompact({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(
            vehicle.isMotor
                ? Icons.two_wheeler_rounded
                : Icons.directions_car_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(vehicle.displayName, style: AppTypography.titleSmall),
          const Spacer(),
          Text(vehicle.plateNumber,
              style: AppTypography.monoMedium.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
