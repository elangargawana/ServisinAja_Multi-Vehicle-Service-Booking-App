// lib/features/workshop/presentation/screens/workshop_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_computed_providers.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/cards/booking_cost_bar.dart';
import 'package:servis_aja/shared/widgets/states/error_state_widget.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

// ── Search query provider ─────────────────────────────────────────────────────
final _workshopSearchProvider = StateProvider.autoDispose<String>((_) => '');

class WorkshopListScreen extends ConsumerWidget {
  const WorkshopListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorkshops = ref.watch(workshopsProvider);
    final query = ref.watch(_workshopSearchProvider);
    final totalCost = ref.watch(totalEstimatedCostProvider);
    final totalDuration = ref.watch(totalEstimatedDurationProvider);
    final vehicleCount = ref.watch(vehicleCountProvider);
    final requiredCategories = ref.watch(sessionVehicleCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Bengkel'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (vehicleCount > 0) {
              context.goNamed(RouteConstants.nameGarage);
            } else {
              context.goNamed(RouteConstants.nameHome);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Ke Beranda',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.goNamed(RouteConstants.nameHome),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              0,
              AppSpacing.pageHorizontal,
              AppSpacing.md,
            ),
            child: _SearchBar(
              onChanged: (q) =>
                  ref.read(_workshopSearchProvider.notifier).state = q,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Booking context reminder ──────────────────────────
          if (vehicleCount > 0)
            BookingCostBar(
              totalCost: totalCost,
              totalDurationMinutes: totalDuration,
              vehicleCount: vehicleCount,
            ),

          Expanded(
            child: asyncWorkshops.when(
              data: (workshops) {
                final filtered = query.trim().isEmpty
                    ? workshops
                    : workshops
                        .where(
                          (w) =>
                              w.name.toLowerCase().contains(query.toLowerCase()) ||
                              w.district.toLowerCase().contains(query.toLowerCase()),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada bengkel untuk "$query"',
                      style: AppTypography.bodyMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.cardGap),
                  itemBuilder: (_, i) => _WorkshopCard(
                    workshop: filtered[i],
                    requiredCategories: requiredCategories,
                  ),
                );
              },
              loading: () => _ShimmerWorkshopList(),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.invalidate(workshopsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari nama bengkel atau area...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

// ── Workshop Card ─────────────────────────────────────────────────────────────

class _WorkshopCard extends StatelessWidget {
  const _WorkshopCard({
    required this.workshop,
    this.requiredCategories = const {},
  });
  final Workshop workshop;
  final Set<String> requiredCategories;

  @override
  Widget build(BuildContext context) {
    final isCompatible = requiredCategories.isEmpty ||
        requiredCategories.every((cat) => workshop.supportsCategory(cat));
    final unsupported = requiredCategories
        .where((cat) => !workshop.supportsCategory(cat))
        .map((c) => c == 'mobil' ? 'Mobil' : 'Motor')
        .toList();

    return GestureDetector(
      onTap: () => context.goNamed(
        RouteConstants.nameWorkshopDetail,
        pathParameters: {RouteConstants.paramWorkshopId: workshop.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo banner ───────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: isCompatible
                    ? AppColors.primaryContainer
                    : AppColors.neutral200,
                child: Icon(
                  Icons.handyman_rounded,
                  size: 48,
                  color: isCompatible
                      ? AppColors.primary
                      : AppColors.neutral500,
                ),
              ),
            ),

            // ── Info ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workshop.name,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            workshop.ratingLabel,
                            style: AppTypography.labelSmall,
                          ),
                          Text(
                            ' (${workshop.reviewCount})',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: AppSpacing.xs2),
                      Expanded(
                        child: Text(
                          '${workshop.district}, ${workshop.city}',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Category chips + compatibility badge
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      ...workshop.categories.map((cat) {
                        return _CategoryPill(label: cat);
                      }),
                      if (requiredCategories.isNotEmpty) ...[
                        if (!isCompatible)
                          _CompatibilityPill(
                            label: 'Tidak Melayani ${unsupported.join(' & ')}',
                            isCompatible: false,
                          )
                        else
                          const _CompatibilityPill(
                            label: 'Cocok',
                            isCompatible: true,
                          ),
                      ],
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
}

class _CompatibilityPill extends StatelessWidget {
  const _CompatibilityPill({
    required this.label,
    required this.isCompatible,
  });
  final String label;
  final bool isCompatible;

  @override
  Widget build(BuildContext context) {
    final bg =
        isCompatible ? AppColors.successContainer : AppColors.errorContainer;
    final fg = isCompatible ? AppColors.successDark : AppColors.errorDark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompatible ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 11,
            color: fg,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall
            .copyWith(color: AppColors.primaryDark, fontSize: 10),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _ShimmerWorkshopList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (_, __) => const ShimmerCard(height: 180),
    );
  }
}
