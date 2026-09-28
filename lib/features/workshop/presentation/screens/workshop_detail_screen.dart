// lib/features/workshop/presentation/screens/workshop_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  const WorkshopDetailScreen({super.key, required this.workshopId});
  final String workshopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorkshops = ref.watch(workshopsProvider);
    final session = ref.watch(bookingSessionProvider);
    final isAlreadySelected = session.selectedWorkshop?.id == workshopId;

    return asyncWorkshops.when(
      data: (workshops) {
        final workshop = workshops.where((w) => w.id == workshopId).firstOrNull;
        if (workshop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bengkel')),
            body: const ErrorStateWidget(message: 'Bengkel tidak ditemukan'),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Sliver AppBar with photo ───────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: BackButton(
                  color: AppColors.white,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(RouteConstants.nameWorkshopList);
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    workshop.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                    ),
                    child: const Center(
                      child: Icon(Icons.handyman_rounded,
                          size: 72, color: AppColors.white),
                    ),
                  ),
                ),
              ),

              // ── Info sections ──────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating + address
                    _InfoSection(workshop: workshop),
                    // Opening hours
                    _OpeningHoursSection(workshop: workshop),
                    // Services
                    _ServicesSection(workshop: workshop),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: StickyBottomBar(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAlreadySelected
                    ? null
                    : () => _selectWorkshop(context, ref, workshop),
                icon: Icon(
                  isAlreadySelected
                      ? Icons.check_rounded
                      : Icons.location_on_rounded,
                  size: 18,
                ),
                label: Text(
                  isAlreadySelected
                      ? 'Bengkel Ini Sudah Dipilih'
                      : session.vehicleConfigs.isEmpty
                          ? 'Pilih Bengkel & Tambah Kendaraan'
                          : 'Pilih Bengkel Ini',
                ),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeightLg),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          itemCount: 4,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (_, __) => const ShimmerCard(height: 80),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(workshopsProvider),
        ),
      ),
    );
  }

  void _selectWorkshop(
      BuildContext context, WidgetRef ref, Workshop workshop) {
    ref.read(bookingSessionProvider.notifier).setWorkshop(workshop);
    final session = ref.read(bookingSessionProvider);

    if (session.vehicleConfigs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${workshop.name} dipilih! Sekarang tambahkan kendaraanmu.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      context.goNamed(RouteConstants.nameGarage);
    } else {
      context.goNamed(RouteConstants.nameSchedule);
    }
  }
}

// ── Info Section ───────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.workshop});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating row
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs2),
              Text(
                workshop.ratingLabel,
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.warning),
              ),
              Text(
                ' • ${workshop.reviewCount} ulasan',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Address
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.elevation1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workshop.address,
                              style: AppTypography.bodyMedium),
                          Text(
                            '${workshop.district}, ${workshop.city}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(workshop.phone, style: AppTypography.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Opening Hours Section ─────────────────────────────────────────────────────

class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection({required this.workshop});
  final Workshop workshop;

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jam Operasional', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.elevation1,
            ),
            child: Column(
              children: workshop.openHours.map((h) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          _days[(h.dayOfWeek - 1) % 7],
                          style: AppTypography.labelMedium,
                        ),
                      ),
                      if (h.isClosed) ...[
                        Text(
                          'Tutup',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '${h.openTime} – ${h.closeTime}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

// ── Services Section ──────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.workshop});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Layanan Tersedia', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: workshop.serviceIds.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(AppRadius.r6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.successDark),
                    const SizedBox(width: AppSpacing.xs2),
                    Text(
                      s.replaceAll('_', ' '),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}
