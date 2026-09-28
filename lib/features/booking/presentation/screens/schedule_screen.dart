// lib/features/booking/presentation/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/extensions/datetime_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/features/workshop/domain/workshop.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

// ── State providers ───────────────────────────────────────────────────────────

/// Currently viewed date on the schedule screen (yyyyMMdd).
final _selectedDateProvider = StateProvider.autoDispose<DateTime>(
  (_) => DateTime.now().add(const Duration(days: 1)), // min: tomorrow
);

/// Currently selected slot ID (before confirming).
final _selectedSlotIdProvider = StateProvider.autoDispose<String?>((_) => null);

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bookingSessionProvider);
    final workshop = session.selectedWorkshop;

    if (workshop == null) {
      // Should not happen, but safety guard
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.goNamed(RouteConstants.nameWorkshopList),
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedDate = ref.watch(_selectedDateProvider);
    final selectedSlotId = ref.watch(_selectedSlotIdProvider);
    final dateStr = _formatDateKey(selectedDate);

    final asyncSlots = ref.watch(
      workshopSlotsProvider((workshopId: workshop.id, date: dateStr)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pilih Jadwal')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Workshop reminder ────────────────────────────────
          _WorkshopReminderBar(workshop: workshop),

          // ── Date picker ──────────────────────────────────────
          _DatePickerRow(
            selectedDate: selectedDate,
            onDateSelected: (d) {
              ref.read(_selectedDateProvider.notifier).state = d;
              ref.read(_selectedSlotIdProvider.notifier).state = null;
            },
          ),

          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── Slot grid ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            child: Row(
              children: [
                Text('Pilih Waktu', style: AppTypography.titleLarge),
                if (session.vehicleConfigs.length > 1) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                    ),
                    child: Text(
                      'Perlu muat ${session.vehicleConfigs.length} unit',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          Expanded(
            child: asyncSlots.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return _NoSlotsState(date: selectedDate);
                }
                return _SlotGrid(
                  slots: slots,
                  selectedId: selectedSlotId,
                  requiredCapacity: session.vehicleConfigs.isNotEmpty
                      ? session.vehicleConfigs.length
                      : 1,
                  onSelect: (id) =>
                      ref.read(_selectedSlotIdProvider.notifier).state = id,
                );
              },
              loading: () => _ShimmerSlots(),
              error: (_, __) => const Center(
                child: Text('Gagal memuat slot. Coba lagi.'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StickyBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedSlotId != null) ...[
              _SelectedSlotSummary(
                date: selectedDate,
                slotId: selectedSlotId,
                asyncSlots: asyncSlots,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selectedSlotId != null
                    ? () => _confirm(context, ref, asyncSlots, selectedSlotId)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeightLg),
                ),
                child: Text(
                  selectedSlotId != null
                      ? 'Konfirmasi Jadwal'
                      : 'Pilih Waktu Terlebih Dahulu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _confirm(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<WorkshopSlot>> asyncSlots,
    String slotId,
  ) {
    final slot = asyncSlots.valueOrNull?.where((s) => s.id == slotId).firstOrNull;
    if (slot == null) return;

    ref.read(bookingSessionProvider.notifier).setSchedule(slot);
    context.goNamed(RouteConstants.nameBookingReview);
  }
}

// ── Workshop Reminder Bar ─────────────────────────────────────────────────────

class _WorkshopReminderBar extends StatelessWidget {
  const _WorkshopReminderBar({required this.workshop});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.borderBrand),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workshop.name, style: AppTypography.titleSmall),
                Text(
                  workshop.district,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date Picker Row ───────────────────────────────────────────────────────────

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Show 14 days starting from tomorrow
    final dates = List.generate(
      14,
      (i) => today.add(Duration(days: i + 1)),
    );

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.sm,
        ),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, i) {
          final d = dates[i];
          final isSelected = d.day == selectedDate.day &&
              d.month == selectedDate.month &&
              d.year == selectedDate.year;
          return _DateChip(
            date: d,
            isSelected: isSelected,
            onTap: () => onDateSelected(d),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDefault,
          ),
          boxShadow: isSelected ? AppShadows.elevation2 : AppShadows.elevation1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdays[(date.weekday - 1) % 7],
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.white.withValues(alpha: 0.8) : AppColors.textTertiary,
              ),
            ),
            Text(
              '${date.day}',
              style: AppTypography.titleLarge.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                height: 1.1,
              ),
            ),
            Text(
              date.toShortMonth(),
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.white.withValues(alpha: 0.8) : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slot Grid ─────────────────────────────────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedId,
    required this.onSelect,
    required this.requiredCapacity,
  });

  final List<WorkshopSlot> slots;
  final String? selectedId;
  final void Function(String) onSelect;
  final int requiredCapacity;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final slot = slots[i];
        final isFull = slot.isFull;
        final hasCapacity = slot.hasCapacityFor(requiredCapacity);
        final isInsufficient = !isFull && !hasCapacity;
        final isSelectable = !isFull && hasCapacity;
        final isSelected = slot.id == selectedId;

        return GestureDetector(
          onTap: isSelectable ? () => onSelect(slot.id) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: !isSelectable
                  ? AppColors.neutral100
                  : isSelected
                      ? AppColors.primary
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: isInsufficient
                    ? AppColors.warning.withValues(alpha: 0.6)
                    : !isSelectable
                        ? AppColors.borderSubtle
                        : isSelected
                            ? AppColors.primary
                            : AppColors.borderDefault,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.time,
                  style: AppTypography.labelMedium.copyWith(
                    color: !isSelectable
                        ? AppColors.textDisabled
                        : isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                  ),
                ),
                if (isFull)
                  Text(
                    'Penuh',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 10,
                    ),
                  )
                else if (isInsufficient)
                  Text(
                    'Sisa ${slot.available} (kurang)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warningDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  Text(
                    '${slot.available} sisa',
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.8)
                          : AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Selected Slot Summary ─────────────────────────────────────────────────────

class _SelectedSlotSummary extends StatelessWidget {
  const _SelectedSlotSummary({
    required this.date,
    required this.slotId,
    required this.asyncSlots,
  });

  final DateTime date;
  final String slotId;
  final AsyncValue<List<WorkshopSlot>> asyncSlots;

  @override
  Widget build(BuildContext context) {
    final slot = asyncSlots.valueOrNull?.where((s) => s.id == slotId).firstOrNull;
    if (slot == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded,
              size: 16, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${date.toLongDate()} • ${slot.time}',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Shimmer states ────────────────────────────────────────────────────

class _NoSlotsState extends StatelessWidget {
  const _NoSlotsState({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy_rounded,
              size: 48, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tidak ada slot tersedia',
            style: AppTypography.titleMedium,
          ),
          Text(
            'Pilih tanggal lain',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ShimmerSlots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.4,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: 12,
      itemBuilder: (_, __) => AppShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
        ),
      ),
    );
  }
}
