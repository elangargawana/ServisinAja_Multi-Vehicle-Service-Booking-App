// lib/features/tracking/presentation/screens/tracking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/extensions/int_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/enums/booking_status.dart';
import 'package:servis_aja/features/booking/domain/enums/service_status.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

/// Service ticket and per-vehicle tracking screen.
/// Core design principle: each vehicle has its own independent status pipeline.
/// User must be able to understand each vehicle's condition at a glance.
class TrackingDetailScreen extends ConsumerWidget {
  const TrackingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBooking = ref.watch(bookingDetailProvider(bookingId));

    return asyncBooking.when(
      data: (booking) {
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tiket Servis')),
            body: ErrorStateWidget(
              message: 'Booking #$bookingId tidak ditemukan',
              onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
            ),
          );
        }
        return _BookingDetailView(booking: booking);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Tiket Servis')),
        body: const _ShimmerDetail(),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Tiket Servis')),
        body: ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
        ),
      ),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _BookingDetailView extends StatelessWidget {
  const _BookingDetailView({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final isAllDone = booking.allVehiclesCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteConstants.nameHome);
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tiket Servis'),
            Text(
              booking.id,
              style: AppTypography.monoMedium.copyWith(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Copy booking ID
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Salin ID Booking',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: booking.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID booking disalin'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In production: re-fetch from API
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Booking Status Hero ──────────────────────────
            SliverToBoxAdapter(
              child: _BookingStatusHero(booking: booking),
            ),

            // ── Workshop + Schedule ──────────────────────────
            SliverToBoxAdapter(
              child: _BookingInfoCard(booking: booking),
            ),

            // ── Multi-vehicle overview strip ─────────────────
            if (booking.vehicles.length > 1)
              SliverToBoxAdapter(
                child: _VehicleOverviewStrip(vehicles: booking.vehicles),
              ),

            // ── Per-vehicle tracking cards ───────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              sliver: SliverList.separated(
                itemCount: booking.vehicles.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.cardGap),
                itemBuilder: (_, i) => _VehicleTrackingCard(
                  vehicle: booking.vehicles[i],
                  index: i + 1,
                  totalVehicles: booking.vehicles.length,
                ),
              ),
            ),

            // ── Cost summary ─────────────────────────────────
            SliverToBoxAdapter(
              child: _CostSummaryCard(booking: booking),
            ),

            // ── Done state CTA ───────────────────────────────
            if (isAllDone)
              SliverToBoxAdapter(
                child: _AllDoneBanner(
                  onGoHome: () =>
                      context.goNamed(RouteConstants.nameHome),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Booking Status Hero ────────────────────────────────────────────────────────

class _BookingStatusHero extends StatelessWidget {
  const _BookingStatusHero({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isAllDone = booking.allVehiclesCompleted;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: isAllDone
            ? AppColors.successGradient
            : AppColors.brandGradient,
        borderRadius: AppRadius.cardLargeRadius,
        boxShadow: AppShadows.elevation2,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Big status icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForStatus(status),
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                    Text(
                      _subTextForStatus(booking),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Booking status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${booking.vehicleCount} Kendaraan',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),

          // Vehicle progress bar (multi-vehicle at a glance)
          if (booking.vehicles.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            _ProgressSummaryRow(vehicles: booking.vehicles),
          ],
        ],
      ),
    );
  }

  IconData _iconForStatus(BookingStatus s) => switch (s) {
        BookingStatus.pendingConfirmation => Icons.pending_rounded,
        BookingStatus.confirmed => Icons.check_circle_outline_rounded,
        BookingStatus.inProgress => Icons.handyman_rounded,
        BookingStatus.completed => Icons.verified_rounded,
        BookingStatus.cancelled => Icons.cancel_rounded,
        _ => Icons.receipt_long_rounded,
      };

  String _subTextForStatus(Booking b) {
    final done =
        b.vehicles.where((v) => v.serviceStatus.isDone).length;
    final total = b.vehicles.length;
    if (b.status == BookingStatus.completed) {
      return 'Semua kendaraan selesai diservis';
    }
    if (done > 0) {
      return '$done dari $total kendaraan selesai';
    }
    return '${b.slotSnapshot.date} pukul ${b.slotSnapshot.time} WIB';
  }
}

class _ProgressSummaryRow extends StatelessWidget {
  const _ProgressSummaryRow({required this.vehicles});
  final List<BookingVehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    final done = vehicles.where((v) => v.serviceStatus.isDone).length;
    final progress = done / vehicles.length;

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$done/${vehicles.length} kendaraan selesai',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.white.withValues(alpha: 0.25),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Booking Info Card ─────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal, 0,
        AppSpacing.pageHorizontal, AppSpacing.cardGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.store_rounded,
            label: 'Bengkel',
            value: booking.workshopSnapshot.name,
            sub: booking.workshopSnapshot.address,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'Jadwal',
            value: '${booking.slotSnapshot.date} • ${booking.slotSnapshot.time} WIB',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: 'Kontak Bengkel',
            value: booking.workshopSnapshot.phone,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
                Text(value, style: AppTypography.titleSmall),
                if (sub != null)
                  Text(sub!,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Overview Strip (multi-vehicle quick scan) ─────────────────────────

class _VehicleOverviewStrip extends StatelessWidget {
  const _VehicleOverviewStrip({required this.vehicles});
  final List<BookingVehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            'Status Semua Kendaraan',
            style: AppTypography.titleMedium,
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, i) =>
                _VehicleStatusChip(vehicle: vehicles[i], index: i + 1),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _VehicleStatusChip extends StatelessWidget {
  const _VehicleStatusChip({required this.vehicle, required this.index});
  final BookingVehicle vehicle;
  final int index;

  @override
  Widget build(BuildContext context) {
    final status = vehicle.serviceStatus;
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: status.containerColor,
        borderRadius: BorderRadius.circular(AppRadius.r10),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status.isDone
                      ? status.color
                      : status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs2),
              Flexible(
                child: Text(
                  'Unit $index',
                  style: AppTypography.labelSmall.copyWith(
                    color: status.color,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            vehicle.vehicleSnapshot.displayName,
            style: AppTypography.bodySmall.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            status.shortLabel,
            style: AppTypography.labelSmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Per-Vehicle Tracking Card ─────────────────────────────────────────────────

class _VehicleTrackingCard extends StatefulWidget {
  const _VehicleTrackingCard({
    required this.vehicle,
    required this.index,
    required this.totalVehicles,
  });

  final BookingVehicle vehicle;
  final int index;
  final int totalVehicles;

  @override
  State<_VehicleTrackingCard> createState() => _VehicleTrackingCardState();
}

class _VehicleTrackingCardState extends State<_VehicleTrackingCard> {
  bool _isExpanded = true; // default expand first vehicle

  @override
  void initState() {
    super.initState();
    // Auto-expand vehicles that are currently in progress
    _isExpanded = widget.vehicle.serviceStatus.isActive ||
        widget.index == 1;
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final status = v.serviceStatus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: status.isDone
              ? AppColors.success.withValues(alpha: 0.4)
              : status.isActive
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
          width: status.isActive ? 1.5 : 1,
        ),
        boxShadow: status.isActive
            ? AppShadows.elevation2
            : AppShadows.elevation1,
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: AppRadius.cardRadius,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  // Status indicator circle
                  _StatusIndicatorCircle(status: status, index: widget.index),
                  const SizedBox(width: AppSpacing.md),

                  // Vehicle info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                v.vehicleSnapshot.displayName,
                                style: AppTypography.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Active badge
                            if (status.isActive)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(
                                    left: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
                              ),
                              child: Text(
                                v.vehicleSnapshot.plateNumber,
                                style: AppTypography.monoMedium
                                    .copyWith(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                v.serviceSnapshot.name,
                                style: AppTypography.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  // Status label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusBadge(status: status),
                      const SizedBox(height: AppSpacing.xs2),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable content ──────────────────────────────
          if (_isExpanded) ...[
            const Divider(height: 1),
            _VehicleTrackingTimeline(vehicle: v),
            const Divider(height: 1),
            _VehicleServiceDetails(vehicle: v),
          ],
        ],
      ),
    );
  }
}

// ── Status Indicator Circle ────────────────────────────────────────────────────

class _StatusIndicatorCircle extends StatelessWidget {
  const _StatusIndicatorCircle({required this.status, required this.index});
  final ServiceStatus status;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (status.isDone) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded,
            color: AppColors.success, size: 22),
      );
    }

    if (status.isActive) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$index',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),
      );
    }

    // waiting
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: status.containerColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(color: status.color),
      ),
    );
  }
}

// ── Vehicle Tracking Timeline ──────────────────────────────────────────────────

class _VehicleTrackingTimeline extends StatelessWidget {
  const _VehicleTrackingTimeline({required this.vehicle});
  final BookingVehicle vehicle;

  // The canonical pipeline steps shown in the timeline
  static const _pipeline = [
    (status: ServiceStatus.waitingArrival, label: 'Menunggu Kedatangan'),
    (status: ServiceStatus.arrived, label: 'Kendaraan Tiba'),
    (status: ServiceStatus.beingInspected, label: 'Pemeriksaan'),
    (status: ServiceStatus.inService, label: 'Proses Servis'),
    (status: ServiceStatus.qualityCheck, label: 'Pemeriksaan Akhir'),
    (status: ServiceStatus.completed, label: 'Selesai'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = vehicle.serviceStatus;
    final currentIdx = ServiceStatus.values.indexOf(current);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Pengerjaan',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              )),
          const SizedBox(height: AppSpacing.md),
          ..._pipeline.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final stepIdx = ServiceStatus.values.indexOf(step.status);
            final isDone = currentIdx >= stepIdx && !_isSkipped(current, step.status);
            final isCurrent = current == step.status;
            final isLast = i == _pipeline.length - 1;

            return _TimelineStep(
              label: step.label,
              isDone: isDone,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: _timestampForStatus(vehicle.statusHistory, step.status),
              assignedMechanic: isCurrent ? vehicle.assignedMechanicName : null,
            );
          }),
        ],
      ),
    );
  }

  bool _isSkipped(ServiceStatus current, ServiceStatus step) {
    // waitingParts is not in the main pipeline — handled separately
    if (step == ServiceStatus.waitingParts) return true;
    // If we passed over a step due to service flow
    return false;
  }

  String? _timestampForStatus(List<StatusEvent> history, ServiceStatus status) {
    try {
      final event = history.firstWhere(
          (e) => ServiceStatus.fromString(e.status) == status);
      final dt = event.timestamp;
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    this.timestamp,
    this.assignedMechanic,
  });

  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final String? timestamp;
  final String? assignedMechanic;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? AppColors.primary
        : isDone
            ? AppColors.success
            : AppColors.neutral300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: dot + line ────────────────────────────────
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : isDone
                            ? AppColors.success
                            : AppColors.neutral200,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isDone && !isCurrent
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12)
                      : isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : AppColors.borderSubtle,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Right: label + info ─────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.titleSmall.copyWith(
                            color: isCurrent
                                ? AppColors.primary
                                : isDone
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                          ),
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          timestamp!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),

                  // Active indicator
                  if (isCurrent) ...[
                    const SizedBox(height: AppSpacing.xs2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs2),
                        Text(
                          'Sedang berlangsung',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (assignedMechanic != null) ...[
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          const Icon(Icons.engineering_rounded,
                              size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: AppSpacing.xs2),
                          Text(
                            assignedMechanic!,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Service Details (collapsed under timeline) ────────────────────────

class _VehicleServiceDetails extends StatelessWidget {
  const _VehicleServiceDetails({required this.vehicle});
  final BookingVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Servis',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Service type
          _DetailChip(
            icon: Icons.build_rounded,
            label: vehicle.serviceSnapshot.name,
          ),

          // Parts
          if (vehicle.selectedParts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            ...vehicle.selectedParts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
                child: _DetailChip(
                  icon: Icons.inventory_2_rounded,
                  label: '${p.name} (×${p.quantity})',
                  trailing: p.subtotal.toCurrency(),
                ),
              ),
            ),
          ],

          // Complaint
          if (vehicle.complaint != null &&
              vehicle.complaint!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(AppRadius.r6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 14, color: AppColors.warningDark),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      vehicle.complaint!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warningDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cost row
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'Estimasi biaya kendaraan ini',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary),
              ),
              const Spacer(),
              Text(
                vehicle.estimatedCost.toCurrency(),
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),

          // Actual cost (if completed)
          if (vehicle.actualCost != null) ...[
            const SizedBox(height: AppSpacing.xs2),
            Row(
              children: [
                Text(
                  'Biaya aktual',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  vehicle.actualCost!.toCurrency(),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(label, style: AppTypography.bodySmall),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.primaryDark),
          ),
      ],
    );
  }
}

// ── Cost Summary Card ──────────────────────────────────────────────────────────

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final isCompleted = booking.status == BookingStatus.completed;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Biaya', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),

          // Per-vehicle rows
          ...booking.vehicles.map(
            (v) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    v.vehicleSnapshot.displayName,
                    style: AppTypography.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    v.estimatedCost.toCurrency(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Text(
                isCompleted ? 'Total Biaya' : 'Estimasi Total',
                style: AppTypography.titleSmall,
              ),
              const Spacer(),
              Text(
                booking.totalEstimatedCost.toCurrency(),
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),

          if (!isCompleted) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '* Biaya final dikonfirmasi bengkel setelah diagnosa',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ── All Done Banner ────────────────────────────────────────────────────────────

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner({required this.onGoHome});
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation2,
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.white, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua kendaraan selesai! 🎉',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Terima kasih telah menggunakan ServisinAja.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onGoHome,
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            child: const Text('Beranda'),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Loading ────────────────────────────────────────────────────────────

class _ShimmerDetail extends StatelessWidget {
  const _ShimmerDetail();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      children: [
        const ShimmerCard(height: 120),
        const SizedBox(height: AppSpacing.cardGap),
        const ShimmerCard(height: 100),
        const SizedBox(height: AppSpacing.cardGap),
        const ShimmerCard(height: 240),
        const SizedBox(height: AppSpacing.cardGap),
        const ShimmerCard(height: 240),
      ],
    );
  }
}
