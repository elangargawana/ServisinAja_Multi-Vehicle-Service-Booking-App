// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/chips/status_badge.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(userVehiclesProvider);
          ref.invalidate(activeBookingsProvider);
          ref.invalidate(workshopsProvider);
        },
        child: CustomScrollView(
          slivers: [
            _HomeAppBar(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            _ActiveBookingSection(),
            _QuickActionSection(),
            _VehicleGarageSection(),
            _NearbyWorkshopSection(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl4)),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          'R',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang,',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              'Rendra Kusuma',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Servis kendaraan,\ncepat & mudah.',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Active Booking Section ─────────────────────────────────────────────────

class _ActiveBookingSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(activeBookingsProvider);

    return asyncBookings.when(
      data: (bookings) {
        if (bookings.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Text('Booking Aktif', style: AppTypography.titleLarge),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.cardGap),
                  itemBuilder: (_, i) => _ActiveBookingCard(booking: bookings[i]),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerText(width: 120),
              const SizedBox(height: AppSpacing.sm),
              ShimmerCard(height: 120),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
          ),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _ActiveBookingCard extends StatelessWidget {
  const _ActiveBookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        RouteConstants.nameTrackingDetail,
        pathParameters: {RouteConstants.paramBookingId: booking.id},
      ),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.elevation2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  booking.id,
                  style: AppTypography.monoMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const Spacer(),
            Text(
              booking.workshopSnapshot.name,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs2),
            Row(
              children: [
                const Icon(Icons.directions_car_rounded,
                    size: 14, color: AppColors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${booking.vehicleCount} kendaraan • '
                  '${booking.slotSnapshot.date} ${booking.slotSnapshot.time}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Section ───────────────────────────────────────────────────

class _QuickActionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apa yang ingin kamu lakukan?',
                style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.sectionHeaderGap),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.build_circle_rounded,
                    label: 'Booking Servis',
                    color: AppColors.primary,
                    onTap: () =>
                        context.goNamed(RouteConstants.nameGarage),
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Riwayat',
                    color: AppColors.secondary,
                    onTap: () =>
                        context.goNamed(RouteConstants.nameBookingHistory),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.elevation1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.labelMedium),
          ],
        ),
      ),
    );
  }
}

// ── Vehicle Garage Section ─────────────────────────────────────────────────

class _VehicleGarageSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVehicles = ref.watch(userVehiclesProvider);

    return asyncVehicles.when(
      data: (vehicles) {
        if (vehicles.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Text('Garasiku', style: AppTypography.titleLarge),
              ),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.cardGap),
                  itemBuilder: (_, i) => _VehicleChip(vehicle: vehicles[i]),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerText(width: 80),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              Row(
                children: [
                  ShimmerCard(height: 112, width: 140),
                  const SizedBox(width: AppSpacing.cardGap),
                  ShimmerCard(height: 112, width: 140),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorStateWidget(message: e.toString()),
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Icon(
              vehicle.isMotor
                  ? Icons.two_wheeler_rounded
                  : Icons.directions_car_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            vehicle.displayName,
            style: AppTypography.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            vehicle.plateNumber,
            style: AppTypography.monoMedium.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Nearby Workshop Section ────────────────────────────────────────────────

class _NearbyWorkshopSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorkshops = ref.watch(workshopsProvider);

    return asyncWorkshops.when(
      data: (workshops) {
        final featured = workshops.take(3).toList();
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Row(
                  children: [
                    Text('Bengkel Terdekat', style: AppTypography.titleLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          context.goNamed(RouteConstants.nameWorkshopList),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              ...featured.map((w) => _WorkshopListTile(workshop: w)),
            ],
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal),
          child: Column(
            children: List.generate(
              2,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                child: ShimmerCard(height: 80),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _WorkshopListTile extends StatelessWidget {
  const _WorkshopListTile({required this.workshop});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ).copyWith(bottom: AppSpacing.cardGap),
      child: GestureDetector(
        onTap: () => context.goNamed(
          RouteConstants.nameWorkshopDetail,
          pathParameters: {RouteConstants.paramWorkshopId: workshop.id},
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardRadius,
            boxShadow: AppShadows.elevation1,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: const Icon(Icons.handyman_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.name,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                    Text(
                      workshop.district,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        workshop.ratingLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Text(
                    '${workshop.reviewCount} ulasan',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
