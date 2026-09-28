// lib/features/booking/presentation/screens/garage_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/extensions/int_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_computed_providers.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';
import 'package:servis_aja/shared/widgets/states/empty_state_widget.dart';

/// The multi-vehicle booking orchestrator screen.
/// This is the heart of the booking flow — user sees all vehicles,
/// their config status, and navigates to configure each one.
class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bookingSessionProvider);
    final totalCost = ref.watch(totalEstimatedCostProvider);
    final totalDuration = ref.watch(totalEstimatedDurationProvider);
    final vehicleCount = ref.watch(vehicleCountProvider);
    final canAdd = ref.watch(canAddMoreVehiclesProvider);
    final isReady = ref.watch(isVehiclesReadyProvider); // all vehicles configured

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Konfigurasi Kendaraan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Batal booking',
          onPressed: () => _handleClose(context, ref, session),
        ),
        actions: [
          if (vehicleCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: _ProgressBadge(
                  done: session.configuredCount,
                  total: vehicleCount,
                ),
              ),
            ),
        ],
      ),
      body: vehicleCount == 0
          ? _EmptyGarageBooking(onAdd: () => _navigateToSelection(context))
          : _VehicleConfigList(session: session, canAdd: canAdd),

      // ── Compact unified bottom bar ─────────────────────────────
      bottomNavigationBar: vehicleCount == 0
          ? null
          : StickyBottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isReady) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(AppRadius.r6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.warningDark),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${session.unconfiguredCount} unit kendaraan belum dipilih jenis servisnya',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warningDark,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      // Total cost & summary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total ($vehicleCount unit${totalDuration > 0 ? " • ~$totalDuration mnt" : ""})',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              totalCost > 0 ? totalCost.toCurrency() : 'Rp 0',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canAdd) ...[
                        OutlinedButton.icon(
                          onPressed: () => _navigateToSelection(context),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Tambah'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: const Size(0, 44),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      FilledButton(
                        onPressed: isReady
                            ? () => context.goNamed(RouteConstants.nameWorkshopList)
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                        ),
                        child: Text(
                          isReady ? 'Pilih Bengkel →' : 'Lengkapi Dulu',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToSelection(BuildContext context) {
    context.goNamed(RouteConstants.nameSelectVehicle);
  }

  void _handleClose(BuildContext context, WidgetRef ref, BookingSession session) {
    if (session.vehicleConfigs.isEmpty) {
      context.pop();
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: const Text(
          'Semua konfigurasi kendaraan yang sudah dibuat akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lanjutkan Booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ref.read(bookingSessionProvider.notifier).resetSession();
        context.pop();
      }
    });
  }
}

// ── Vehicle Config List ────────────────────────────────────────────────────────

class _VehicleConfigList extends StatelessWidget {
  const _VehicleConfigList({required this.session, required this.canAdd});
  final BookingSession session;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: session.vehicleConfigs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (_, i) => _VehicleConfigCard(
        config: session.vehicleConfigs[i],
        index: i + 1,
        onTap: () => context.goNamed(
          RouteConstants.nameVehicleConfig,
          pathParameters: {
            RouteConstants.paramVehicleId:
                session.vehicleConfigs[i].vehicle.id,
          },
        ),
        onRemove: () {},
      ),
    );
  }
}

// ── Vehicle Config Card ────────────────────────────────────────────────────────

class _VehicleConfigCard extends ConsumerWidget {
  const _VehicleConfigCard({
    required this.config,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  final VehicleConfig config;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConfigured = config.isConfigured;

    return Dismissible(
      key: ValueKey(config.vehicle.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) => _confirmRemove(context, config.vehicle.displayName),
      onDismissed: (_) {
        ref
            .read(bookingSessionProvider.notifier)
            .removeVehicle(config.vehicle.id);
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: isConfigured
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.borderDefault,
              width: isConfigured ? 1.5 : 1,
            ),
            boxShadow: AppShadows.elevation1,
          ),
          child: Column(
            children: [
              // ── Header row ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  children: [
                    // Number badge
                    _NumberBadge(
                      number: index,
                      isConfigured: isConfigured,
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Vehicle info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.vehicle.displayName,
                            style: AppTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs2),
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
                                  border:
                                      Border.all(color: AppColors.borderDefault),
                                ),
                                child: Text(
                                  config.vehicle.plateNumber,
                                  style: AppTypography.monoMedium.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                config.vehicle.isMotor ? 'Motor' : 'Mobil',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status icon
                    _ConfigStatusIcon(isConfigured: isConfigured),
                  ],
                ),
              ),

              // ── Config summary (shown if configured) ──────────
              if (isConfigured) ...[
                const Divider(height: 1),
                _ConfigSummaryRow(config: config),
              ] else ...[
                const Divider(height: 1),
                _NotConfiguredRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus kendaraan?'),
        content: Text(
          '$name akan dihapus dari booking ini. Konfigurasinya akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.isConfigured});
  final int number;
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isConfigured ? AppColors.successContainer : AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: AppTypography.titleSmall.copyWith(
            color: isConfigured ? AppColors.successDark : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _ConfigStatusIcon extends StatelessWidget {
  const _ConfigStatusIcon({required this.isConfigured});
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    if (isConfigured) {
      return const Icon(Icons.check_circle_rounded,
          color: AppColors.success, size: 24);
    }
    return const Icon(Icons.edit_rounded, color: AppColors.neutral400, size: 24);
  }
}

class _ConfigSummaryRow extends StatelessWidget {
  const _ConfigSummaryRow({required this.config});
  final VehicleConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Service name
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.build_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    config.selectedService!.name,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Parts count
          if (config.selectedParts.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              '+${config.selectedParts.length} part',
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textTertiary),
            ),
          ],

          const SizedBox(width: AppSpacing.sm),

          // Estimated cost
          Text(
            config.estimatedCost.toCurrency(),
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class _NotConfiguredRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Belum dikonfigurasi — ketuk untuk mengisi',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textWarning),
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.cardRadius,
      ),
      child: const Icon(Icons.delete_rounded, color: AppColors.error),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyGarageBooking extends StatelessWidget {
  const _EmptyGarageBooking({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.add_road_rounded,
      title: 'Belum ada kendaraan',
      subtitle:
          'Tambahkan kendaraan yang ingin diservis. Kamu bisa pilih lebih dari satu.',
      actionLabel: 'Pilih Kendaraan',
      onAction: onAdd,
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final allDone = done == total;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: allDone ? AppColors.successContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$done/$total selesai',
        style: AppTypography.labelSmall.copyWith(
          color: allDone ? AppColors.successDark : AppColors.primaryDark,
        ),
      ),
    );
  }
}


