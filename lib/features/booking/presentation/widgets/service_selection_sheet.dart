// lib/features/booking/presentation/widgets/service_selection_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/core/extensions/int_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/service_type.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

/// Shows a bottom sheet for selecting service type.
/// Returns the selected [ServiceType] when dismissed.
Future<ServiceType?> showServiceSelectionSheet({
  required BuildContext context,
  required String vehicleCategoryId,
  ServiceType? currentSelection,
}) {
  return showModalBottomSheet<ServiceType>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (_) => _ServiceSelectionSheet(
      vehicleCategoryId: vehicleCategoryId,
      currentSelection: currentSelection,
    ),
  );
}

class _ServiceSelectionSheet extends ConsumerWidget {
  const _ServiceSelectionSheet({
    required this.vehicleCategoryId,
    this.currentSelection,
  });

  final String vehicleCategoryId;
  final ServiceType? currentSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncServices =
        ref.watch(serviceTypesForCategoryProvider(vehicleCategoryId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // ── Handle ───────────────────────────────────────────
            _SheetHandle(),
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Jenis Servis',
                            style: AppTypography.headlineSmall),
                        Text(
                          vehicleCategoryId == 'motor'
                              ? 'Motor'
                              : 'Mobil',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: asyncServices.when(
                data: (services) => ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: services.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.cardGap),
                  itemBuilder: (_, i) => _ServiceCard(
                    service: services[i],
                    vehicleCategoryId: vehicleCategoryId,
                    isSelected: currentSelection?.id == services[i].id,
                    onTap: () => Navigator.pop(context, services[i]),
                  ),
                ),
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: 4,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.cardGap),
                  itemBuilder: (_, __) => const ShimmerCard(height: 88),
                ),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Service Card ───────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.vehicleCategoryId,
    required this.isSelected,
    required this.onTap,
  });

  final ServiceType service;
  final String vehicleCategoryId;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _accentColor {
    // Parse hex to Color
    try {
      final hex = service.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = service.basePriceFor(vehicleCategoryId);
    final duration = service.durationFor(vehicleCategoryId);
    final isFree = price == 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.r10),
              ),
              child: Icon(
                _iconFor(service.iconName),
                color: _accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: AppTypography.titleMedium,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Text(
                    service.description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Price + duration row
                  Row(
                    children: [
                      Icon(Icons.payments_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: AppSpacing.xs2),
                      Text(
                        isFree ? 'Harga dikonfirmasi bengkel' : 'Mulai ${price.toCurrency()}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isFree
                              ? AppColors.textTertiary
                              : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.timer_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: AppSpacing.xs2),
                      Text(
                        duration.toDurationLabel(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) => switch (name) {
        'ic_service_periodic' => Icons.autorenew_rounded,
        'ic_service_tuneup' => Icons.speed_rounded,
        'ic_service_oil' => Icons.water_drop_rounded,
        'ic_service_brake' => Icons.disc_full_rounded,
        'ic_service_overhaul' => Icons.engineering_rounded,
        _ => Icons.build_rounded,
      };
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}
