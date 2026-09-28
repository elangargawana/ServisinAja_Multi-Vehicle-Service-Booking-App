// lib/features/workshop/presentation/screens/workshop_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/asset_constants.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/errors/app_exception.dart';
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

class WorkshopDetailScreen extends ConsumerStatefulWidget {
  const WorkshopDetailScreen({super.key, required this.workshopId});
  final String workshopId;

  @override
  ConsumerState<WorkshopDetailScreen> createState() =>
      _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends ConsumerState<WorkshopDetailScreen> {
  late final ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isCollapsed = _scrollController.offset > 110;
    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncWorkshops = ref.watch(workshopsProvider);
    final session = ref.watch(bookingSessionProvider);
    final isAlreadySelected = session.selectedWorkshop?.id == widget.workshopId;

    return asyncWorkshops.when(
      data: (workshops) {
        final workshop =
            workshops.where((w) => w.id == widget.workshopId).firstOrNull;
        if (workshop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bengkel')),
            body: const ErrorStateWidget(message: 'Bengkel tidak ditemukan'),
          );
        }

        final incompatibleConfigs = session.vehicleConfigs
            .where((c) => !workshop.supportsCategory(c.vehicle.categoryId))
            .toList();
        final isCompatible = incompatibleConfigs.isEmpty;
        final unsupportedLabels = incompatibleConfigs
            .map((c) => c.vehicle.isMobil ? 'Mobil' : 'Motor')
            .toSet()
            .join(' & ');
        final workshopLabels = workshop.categories
            .map((c) => c == 'mobil' ? 'Mobil' : 'Motor')
            .join(' & ');

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Sliver AppBar with photo ───────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor:
                    _isCollapsed ? AppColors.surface : AppColors.primary,
                elevation: _isCollapsed ? 1 : 0,
                shadowColor: Colors.black12,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: _isCollapsed
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed(RouteConstants.nameWorkshopList);
                        }
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: _isCollapsed
                            ? AppColors.textPrimary
                            : AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56,
                    end: 56,
                    bottom: 16,
                  ),
                  title: Text(
                    workshop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: _isCollapsed
                          ? AppColors.textPrimary
                          : AppColors.white,
                      fontWeight: FontWeight.w700,
                      shadows: _isCollapsed
                          ? null
                          : const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 8,
                              ),
                            ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        AssetConstants.workshopHeaderNetworkUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          AssetConstants.workshopHeaderBg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
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
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ],
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
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: StickyBottomBar(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompatible) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bengkel Tidak Sesuai Kendaraan',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bengkel ini hanya melayani $workshopLabels. Pesananmu membutuhkan bengkel yang melayani $unsupportedLabels.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isCompatible
                        ? () => _selectWorkshop(context, ref, workshop)
                        : null,
                    icon: Icon(
                      !isCompatible
                          ? Icons.block_rounded
                          : isAlreadySelected
                              ? Icons.arrow_forward_rounded
                              : Icons.location_on_rounded,
                      size: 18,
                    ),
                    label: Text(
                      !isCompatible
                          ? 'Tidak Melayani $unsupportedLabels (Hanya $workshopLabels)'
                          : isAlreadySelected
                              ? (session.vehicleConfigs.isEmpty
                                  ? 'Pilih Bengkel & Tambah Kendaraan'
                                  : 'Lanjut dengan Bengkel Ini')
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
              ],
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
    try {
      ref.read(bookingSessionProvider.notifier).setWorkshop(workshop);
    } on BusinessRuleException catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      return;
    }

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
