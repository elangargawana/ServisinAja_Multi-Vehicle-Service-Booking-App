// lib/features/booking/presentation/widgets/spare_part_selection_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servis_aja/core/extensions/int_extension.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/booking/domain/spare_part.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/states/loading_shimmer.dart';

/// Shows a bottom sheet for selecting spare parts/oli.
/// Returns the final [List<SparePartSelection>] on close.
Future<List<SparePartSelection>?> showSparePartSelectionSheet({
  required BuildContext context,
  required String vehicleCategoryId,
  required String serviceId,
  required List<SparePartSelection> currentSelections,
}) {
  return showModalBottomSheet<List<SparePartSelection>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (_) => _SparePartSelectionSheet(
      vehicleCategoryId: vehicleCategoryId,
      serviceId: serviceId,
      currentSelections: currentSelections,
    ),
  );
}

class _SparePartSelectionSheet extends ConsumerStatefulWidget {
  const _SparePartSelectionSheet({
    required this.vehicleCategoryId,
    required this.serviceId,
    required this.currentSelections,
  });

  final String vehicleCategoryId;
  final String serviceId;
  final List<SparePartSelection> currentSelections;

  @override
  ConsumerState<_SparePartSelectionSheet> createState() =>
      _SparePartSelectionSheetState();
}

class _SparePartSelectionSheetState
    extends ConsumerState<_SparePartSelectionSheet> {
  late List<SparePartSelection> _selections;
  String _activeCategory = 'semua';

  static const _categories = [
    (id: 'semua', label: 'Semua'),
    (id: 'oli', label: 'Oli'),
    (id: 'filter', label: 'Filter'),
    (id: 'busi', label: 'Busi'),
    (id: 'kampas', label: 'Kampas Rem'),
    (id: 'aki', label: 'Aki'),
    (id: 'lainnya', label: 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _selections = List.from(widget.currentSelections);
  }

  int get _subtotal =>
      _selections.fold(0, (sum, p) => sum + p.subtotal);

  bool _isSelected(String partId) =>
      _selections.any((p) => p.partId == partId);

  int _quantityOf(String partId) {
    try {
      return _selections.firstWhere((p) => p.partId == partId).quantity;
    } catch (_) {
      return 0;
    }
  }

  void _togglePart(SparePart part) {
    final price = part.priceFor(widget.vehicleCategoryId);
    if (price == null) return;

    setState(() {
      final idx = _selections.indexWhere((p) => p.partId == part.id);
      if (idx >= 0) {
        _selections.removeAt(idx);
      } else {
        _selections.add(SparePartSelection(
          partId: part.id,
          name: part.name,
          brand: part.brand,
          quantity: 1,
          unitPrice: price,
        ));
      }
    });
  }

  void _updateQty(String partId, int delta) {
    setState(() {
      final idx = _selections.indexWhere((p) => p.partId == partId);
      if (idx < 0) return;
      final current = _selections[idx];
      final newQty = current.quantity + delta;
      if (newQty <= 0) {
        _selections.removeAt(idx);
      } else {
        _selections[idx] = current.copyWith(quantity: newQty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncParts = ref.watch(
      sparePartsForServiceProvider((
        categoryId: widget.vehicleCategoryId,
        serviceId: widget.serviceId,
      )),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // ── Handle ────────────────────────────────────────────
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
                        Text('Spare Part & Oli',
                            style: AppTypography.headlineSmall),
                        Text(
                          'Opsional — pilih sesuai kebutuhan',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _selections),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // ── Category filter ──────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = cat.id == _activeCategory;
                  return FilterChip(
                    label: Text(cat.label),
                    selected: isActive,
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _activeCategory = cat.id),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.borderDefault,
                    ),
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1),

            // ── Parts list ───────────────────────────────────────
            Expanded(
              child: asyncParts.when(
                data: (parts) {
                  final filtered = _activeCategory == 'semua'
                      ? parts
                      : parts
                          .where((p) => p.category == _activeCategory)
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada spare part untuk kategori ini',
                        style: AppTypography.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.cardGap),
                    itemBuilder: (_, i) => _PartCard(
                      part: filtered[i],
                      vehicleCategoryId: widget.vehicleCategoryId,
                      isSelected: _isSelected(filtered[i].id),
                      quantity: _quantityOf(filtered[i].id),
                      onToggle: () => _togglePart(filtered[i]),
                      onIncrement: () =>
                          _updateQty(filtered[i].id, 1),
                      onDecrement: () =>
                          _updateQty(filtered[i].id, -1),
                    ),
                  );
                },
                loading: () => ListView.separated(
                  padding:
                      const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: 5,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.cardGap),
                  itemBuilder: (_, __) => const ShimmerCard(height: 76),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),

            // ── Bottom confirm bar ────────────────────────────────
            _ConfirmBar(
              selectedCount: _selections.length,
              subtotal: _subtotal,
              onConfirm: () => Navigator.pop(context, _selections),
              onClear: _selections.isNotEmpty
                  ? () => setState(() => _selections.clear())
                  : null,
            ),
          ],
        );
      },
    );
  }
}

// ── Part Card ──────────────────────────────────────────────────────────────────

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.part,
    required this.vehicleCategoryId,
    required this.isSelected,
    required this.quantity,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  final SparePart part;
  final String vehicleCategoryId;
  final bool isSelected;
  final int quantity;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final price = part.priceFor(vehicleCategoryId);
    if (price == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryContainer.withValues(alpha: 0.25)
            : AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderDefault,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.r4),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.neutral300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Part info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        part.name,
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    if (part.isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppRadius.r4),
                        ),
                        child: Text(
                          'Rekomendasi',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.successDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs2),
                Text(
                  part.brand,
                  style: AppTypography.bodySmall,
                ),
                if (part.description != null) ...[
                  const SizedBox(height: AppSpacing.xs2),
                  Text(
                    part.description!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      '${price.toCurrency()} / ${part.unit}',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.primaryDark),
                    ),
                    const Spacer(),
                    // Quantity stepper (only visible when selected)
                    if (isSelected)
                      _QuantityStepper(
                        quantity: quantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
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

// ── Quantity Stepper ───────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          color: quantity <= 1 ? AppColors.errorContainer : AppColors.neutral100,
          iconColor: quantity <= 1 ? AppColors.error : AppColors.textSecondary,
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$quantity',
              style: AppTypography.titleSmall,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          onTap: onIncrement,
          color: AppColors.primaryContainer,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.r6),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

// ── Confirm Bar ────────────────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.selectedCount,
    required this.subtotal,
    required this.onConfirm,
    this.onClear,
  });

  final int selectedCount;
  final int subtotal;
  final VoidCallback onConfirm;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.md + bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCount > 0
                      ? '$selectedCount item dipilih'
                      : 'Tidak ada item dipilih',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
                if (selectedCount > 0)
                  Text(
                    subtotal.toCurrency(),
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.primaryDark),
                  ),
              ],
            ),
          ),
          // Clear button
          if (onClear != null) ...[
            TextButton(
              onPressed: onClear,
              child: const Text('Reset'),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          // Confirm
          FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              minimumSize:
                  const Size(0, AppSpacing.buttonHeightMd),
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
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
