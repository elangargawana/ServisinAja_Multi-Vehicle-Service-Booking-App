// lib/features/vehicles/presentation/screens/vehicle_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/app_constants.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/errors/app_exception.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_computed_providers.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/cards/vehicle_card.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';
import 'package:servis_aja/shared/widgets/states/empty_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

/// Screen: "Tambah Kendaraan ke Booking"
/// User selects which vehicles to include from their garage.
/// Accessed from GarageScreen via FAB.
class VehicleSelectionScreen extends ConsumerWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFiltered = ref.watch(filteredVehiclesProvider);
    final session = ref.watch(bookingSessionProvider);
    final vehicleCount = ref.watch(vehicleCountProvider);
    final canAdd = ref.watch(canAddMoreVehiclesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Kendaraan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteConstants.nameGarage);
            }
          },
          tooltip: 'Tutup',
        ),
        actions: [
          // Vehicle count badge
          if (vehicleCount > 0)
            Padding(
              padding:
                  const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: _CountBadge(count: vehicleCount),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ─────────────────────────────────────────
          _CategoryFilterBar(),
          const SizedBox(height: AppSpacing.xs),

          // ── Vehicle list ─────────────────────────────────────────
          Expanded(
            child: asyncFiltered.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.garage_rounded,
                    title: 'Tidak ada kendaraan',
                    subtitle:
                        'Belum ada kendaraan yang sesuai filter, atau garasi masih kosong.',
                    actionLabel: 'Tambah Kendaraan Baru',
                    onAction: () =>
                        context.goNamed(RouteConstants.nameAddVehicle),
                  );
                }
                return _VehicleList(
                  vehicles: vehicles,
                  session: session,
                  canAdd: canAdd,
                );
              },
              loading: () => _ShimmerList(),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.invalidate(userVehiclesProvider),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar: add new / confirm ────────────────────────────
      bottomNavigationBar: _SelectionBottomBar(
        vehicleCount: vehicleCount,
        canAdd: canAdd,
      ),
    );
  }
}

// ── Category Filter Bar ────────────────────────────────────────────────────────

class _CategoryFilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(vehicleCategoryFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.xs),
        itemCount: VehicleCategoryFilter.values.length,
        itemBuilder: (_, i) {
          final filter = VehicleCategoryFilter.values[i];
          final isActive = filter == active;
          return FilterChip(
            label: Text(filter.label),
            selected: isActive,
            onSelected: (_) => ref
                .read(vehicleCategoryFilterProvider.notifier)
                .state = filter,
            selectedColor: AppColors.primaryContainer,
            checkmarkColor: AppColors.primary,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: isActive
                  ? AppColors.borderBrand
                  : AppColors.borderDefault,
            ),
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 0,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

// ── Vehicle List ───────────────────────────────────────────────────────────────

class _VehicleList extends ConsumerWidget {
  const _VehicleList({
    required this.vehicles,
    required this.session,
    required this.canAdd,
  });

  final List<Vehicle> vehicles;
  final dynamic session; // BookingSession
  final bool canAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: vehicles.length + 1, // +1 for "Add new" row at bottom
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (context, i) {
        if (i == vehicles.length) {
          return _AddNewVehicleRow();
        }
        final v = vehicles[i];
        final isAlreadyAdded = session.vehicleAlreadyAdded(v.id);

        return VehicleCard(
          vehicle: v,
          isSelected: isAlreadyAdded,
          isDisabled: !canAdd && !isAlreadyAdded,
          onTap: () => _handleTap(context, ref, v, isAlreadyAdded),
          trailing: isAlreadyAdded
              ? _RemoveButton(
                  onRemove: () => ref
                      .read(bookingSessionProvider.notifier)
                      .removeVehicle(v.id),
                )
              : null,
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
    bool isAlreadyAdded,
  ) {
    if (isAlreadyAdded) {
      // Already added — remove it
      ref.read(bookingSessionProvider.notifier).removeVehicle(vehicle.id);
      return;
    }

    // Try to add
    try {
      ref.read(bookingSessionProvider.notifier).addVehicle(vehicle);
      // Light haptic / snackbar feedback
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${vehicle.displayName} ditambahkan ke booking',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } on BusinessRuleException catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
    } on DuplicateException catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(e.message)),
        );
    }
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onRemove});
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.remove_rounded,
          color: AppColors.error,
          size: 16,
        ),
      ),
    );
  }
}

class _AddNewVehicleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.goNamed(RouteConstants.nameAddVehicle),
      style: OutlinedButton.styleFrom(
        minimumSize:
            const Size(double.infinity, AppSpacing.buttonHeightMd),
        side: const BorderSide(
          color: AppColors.primary,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
      ),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Kendaraan Baru'),
    );
  }
}

// ── Shimmer Skeleton ───────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: 4,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (_, __) => const ShimmerCard(height: 96),
    );
  }
}

// ── Count Badge ────────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$count/${AppConstants.maxVehiclesPerBooking}',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

// ── Selection Bottom Bar ────────────────────────────────────────────────────────

class _SelectionBottomBar extends ConsumerWidget {
  const _SelectionBottomBar({
    required this.vehicleCount,
    required this.canAdd,
  });

  final int vehicleCount;
  final bool canAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StickyBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Max limit warning
          if (!canAdd) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.warningDark),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Maksimal ${AppConstants.maxVehiclesPerBooking} kendaraan per booking',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warningDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Main CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: vehicleCount > 0
                  ? () => context.goNamed(RouteConstants.nameGarage)
                  : null,
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, AppSpacing.buttonHeightLg),
              ),
              child: Text(
                vehicleCount > 0
                    ? 'Konfirmasi ($vehicleCount Kendaraan)'
                    : 'Pilih Kendaraan Terlebih Dahulu',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
