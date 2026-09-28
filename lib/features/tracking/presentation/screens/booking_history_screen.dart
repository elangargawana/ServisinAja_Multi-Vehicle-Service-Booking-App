// lib/features/tracking/presentation/screens/booking_history_screen.dart
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
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/chips/status_badge.dart';
import 'package:servis_aja/shared/widgets/states/empty_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

/// Screen: Booking history & active tickets list.
/// Segregates active in-progress bookings and past completed/cancelled bookings.
class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Riwayat & Tiket Servis'),
          leading: BackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(RouteConstants.nameHome);
              }
            },
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppTypography.titleSmall,
            tabs: const [
              Tab(text: 'Sedang Berjalan'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActiveBookingsTab(),
            _CompletedBookingsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Active Bookings Tab ────────────────────────────────────────────────────────

class _ActiveBookingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(activeBookingsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBookingsProvider);
      },
      child: asyncBookings.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.calendar_today_rounded,
                title: 'Tidak Ada Booking Aktif',
                subtitle:
                    'Kamu belum memiliki jadwal servis kendaraan yang sedang berlangsung.',
                actionLabel: 'Booking Servis Sekarang',
                onAction: () => context.goNamed(RouteConstants.nameGarage),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: bookings.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (_, i) => _BookingHistoryCard(booking: bookings[i]),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (_, __) => const ShimmerCard(height: 150),
        ),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(userBookingsProvider),
        ),
      ),
    );
  }
}

// ── Completed Bookings Tab ─────────────────────────────────────────────────────

class _CompletedBookingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(bookingHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBookingsProvider);
      },
      child: asyncBookings.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.history_rounded,
                title: 'Belum Ada Riwayat Selesai',
                subtitle:
                    'Riwayat servis yang telah selesai akan diarsipkan di sini.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: bookings.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (_, i) => _BookingHistoryCard(booking: bookings[i]),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (_, __) => const ShimmerCard(height: 150),
        ),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(userBookingsProvider),
        ),
      ),
    );
  }
}

// ── Booking History Card ───────────────────────────────────────────────────────

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.goNamed(
        RouteConstants.nameTrackingDetail,
        pathParameters: {RouteConstants.paramBookingId: booking.id},
      ),
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Status badge
            Row(
              children: [
                Text(
                  booking.id,
                  style: AppTypography.monoMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const Divider(height: AppSpacing.md),

            // Workshop & Schedule
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.workshopSnapshot.name,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${booking.slotSnapshot.date} • ${booking.slotSnapshot.time} WIB',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Vehicle summary chips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppRadius.r6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: booking.vehicles.map((v) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${v.vehicleSnapshot.displayName} (${v.vehicleSnapshot.plateNumber}) • ${v.serviceSnapshot.name}',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          v.serviceStatus.shortLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: v.serviceStatus.color,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Footer: Cost + Action indicator
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Estimasi',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      booking.totalEstimatedCost.toCurrency(),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Lacak Tiket',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
