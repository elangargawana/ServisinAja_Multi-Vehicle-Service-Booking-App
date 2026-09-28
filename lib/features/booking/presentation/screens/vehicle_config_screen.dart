// lib/features/booking/presentation/screens/vehicle_config_screen.dart
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
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/features/booking/presentation/widgets/service_selection_sheet.dart';
import 'package:servis_aja/features/booking/presentation/widgets/spare_part_selection_sheet.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';

/// Per-vehicle configuration screen.
/// User sets: service type, spare parts, and complaint notes for ONE vehicle.
/// State is persisted in [BookingSession] so navigating away and back is safe.
class VehicleConfigScreen extends ConsumerStatefulWidget {
  const VehicleConfigScreen({super.key, required this.vehicleId});
  final String vehicleId;

  @override
  ConsumerState<VehicleConfigScreen> createState() =>
      _VehicleConfigScreenState();
}

class _VehicleConfigScreenState extends ConsumerState<VehicleConfigScreen> {
  final _complaintController = TextEditingController();
  bool _complaintDirty = false;

  VehicleConfig? get _config =>
      ref.read(bookingSessionProvider).configFor(widget.vehicleId);

  @override
  void initState() {
    super.initState();
    // Restore saved complaint text when screen opens
    final saved = _config?.complaintText ?? '';
    _complaintController.text = saved;
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch only this vehicle's config — prevents unnecessary rebuilds
    final session = ref.watch(bookingSessionProvider);
    final config = session.configFor(widget.vehicleId);

    // If vehicle was removed while on this screen
    if (config == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final vehicle = config.vehicle;
    final isConfigured = config.isConfigured;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteConstants.nameGarage);
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vehicle.displayName),
            Text(
              session.vehicleConfigs.length > 1
                  ? 'Unit ${session.vehicleConfigs.indexWhere((c) => c.vehicle.id == widget.vehicleId) + 1} dari ${session.vehicleConfigs.length} • ${vehicle.plateNumber}'
                  : vehicle.plateNumber,
              style: AppTypography.monoMedium.copyWith(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Config status indicator
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: isConfigured
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 22)
                  : const Icon(Icons.radio_button_unchecked_rounded,
                      color: AppColors.neutral300, size: 22),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Vehicle Hero ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _VehicleHeroCard(config: config),
          ),

          // ── Section 1: Service Type ───────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              number: 1,
              title: 'Jenis Servis',
              subtitle: 'Pilih satu jenis servis *',
              isRequired: true,
              isComplete: config.selectedService != null,
              child: _ServiceSection(
                config: config,
                onSelectService: () => _openServiceSheet(context, config),
                onClear: config.selectedService != null
                    ? () => _clearService()
                    : null,
              ),
            ),
          ),

          // ── Section 2: Spare Parts (only after service selected) ──
          SliverToBoxAdapter(
            child: AnimatedOpacity(
              opacity: config.selectedService != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: _SectionCard(
                number: 2,
                title: 'Spare Part & Oli',
                subtitle: 'Opsional — dapat diubah saat servis',
                isRequired: false,
                isComplete: config.selectedParts.isNotEmpty,
                child: _SparePartSection(
                  config: config,
                  isEnabled: config.selectedService != null,
                  onSelectParts: () => _openPartsSheet(context, config),
                ),
              ),
            ),
          ),

          // ── Section 3: Complaint / Notes ──────────────────────
          SliverToBoxAdapter(
            child: AnimatedOpacity(
              opacity: config.selectedService != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: _SectionCard(
                number: 3,
                title: 'Keluhan & Catatan',
                subtitle: 'Opsional — bantu mekanik memahami masalah',
                isRequired: false,
                isComplete:
                    config.complaintText.trim().isNotEmpty,
                child: _ComplaintSection(
                  isEnabled: config.selectedService != null,
                  controller: _complaintController,
                  onChanged: (text) {
                    if (!_complaintDirty) {
                      setState(() => _complaintDirty = true);
                    }
                    ref
                        .read(bookingSessionProvider.notifier)
                        .updateComplaint(widget.vehicleId, text);
                  },
                ),
              ),
            ),
          ),

          // ── Bottom padding ────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),

      bottomNavigationBar: _ConfigBottomBar(
        config: config,
        session: session,
        currentIndex: session.vehicleConfigs
            .indexWhere((c) => c.vehicle.id == widget.vehicleId),
      ),
    );
  }

  Future<void> _openServiceSheet(
      BuildContext context, VehicleConfig config) async {
    final selected = await showServiceSelectionSheet(
      context: context,
      vehicleCategoryId: config.vehicle.categoryId,
      currentSelection: config.selectedService,
    );

    if (selected != null && mounted) {
      ref
          .read(bookingSessionProvider.notifier)
          .setServiceForVehicle(widget.vehicleId, selected);
    }
  }

  Future<void> _openPartsSheet(
      BuildContext context, VehicleConfig config) async {
    if (config.selectedService == null) return;

    final result = await showSparePartSelectionSheet(
      context: context,
      vehicleCategoryId: config.vehicle.categoryId,
      serviceId: config.selectedService!.id,
      currentSelections: config.selectedParts,
    );

    if (result != null && mounted) {
      // Replace entire parts list atomically
      final notifier = ref.read(bookingSessionProvider.notifier);
      // Clear existing then set new
      final updatedConfig = config.copyWith(selectedParts: result);
      notifier.saveVehicleConfig(widget.vehicleId, updatedConfig);
    }
  }

  void _clearService() {
    final config = _config;
    if (config == null) return;
    final cleared = config.copyWith(
      clearService: true,
      selectedParts: [],
      complaintText: config.complaintText,
    );
    ref
        .read(bookingSessionProvider.notifier)
        .saveVehicleConfig(widget.vehicleId, cleared);
  }
}

// ── Vehicle Hero Card ──────────────────────────────────────────────────────────

class _VehicleHeroCard extends StatelessWidget {
  const _VehicleHeroCard({required this.config});
  final VehicleConfig config;

  @override
  Widget build(BuildContext context) {
    final v = config.vehicle;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.cardLargeRadius,
        boxShadow: AppShadows.elevation2,
      ),
      child: Row(
        children: [
          // Vehicle icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Icon(
              v.isMotor
                  ? Icons.two_wheeler_rounded
                  : Icons.directions_car_rounded,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Vehicle details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.displayName,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs2),
                Row(
                  children: [
                    Text(
                      v.plateNumber,
                      style: AppTypography.monoMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    if (v.year != null) ...[
                      Text(
                        ' • ${v.year}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs2,
            ),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              v.isMotor ? 'Motor' : 'Mobil',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isRequired,
    required this.isComplete,
    required this.child,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool isRequired;
  final bool isComplete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.cardGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Step number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? AppColors.success
                        : AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isComplete
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : Text(
                            '$number',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTypography.titleMedium),
                          if (isRequired) ...[
                            const SizedBox(width: AppSpacing.xs2),
                            Text(
                              '*',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(subtitle, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Content ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Service Section ────────────────────────────────────────────────────────────

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({
    required this.config,
    required this.onSelectService,
    this.onClear,
  });

  final VehicleConfig config;
  final VoidCallback onSelectService;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final service = config.selectedService;

    if (service == null) {
      return _SelectButton(
        icon: Icons.build_circle_rounded,
        label: 'Pilih Jenis Servis',
        hint: 'Servis berkala, tune-up, ganti oli...',
        onTap: onSelectService,
      );
    }

    // Show selected service with edit option
    final price = service.basePriceFor(config.vehicle.categoryId);
    final duration = service.durationFor(config.vehicle.categoryId);

    return Row(
      children: [
        // Service color indicator
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.r10),
          ),
          child: const Icon(Icons.build_rounded,
              color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service.name, style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs2),
              Row(
                children: [
                  Text(
                    price > 0 ? 'Mulai ${price.toCurrency()}' : 'Sesuai diagnosa',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    duration.toDurationLabel(),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Edit button
        TextButton(
          onPressed: onSelectService,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            minimumSize: Size.zero,
          ),
          child: const Text('Ganti'),
        ),
      ],
    );
  }
}

// ── Spare Part Section ─────────────────────────────────────────────────────────

class _SparePartSection extends StatelessWidget {
  const _SparePartSection({
    required this.config,
    required this.isEnabled,
    required this.onSelectParts,
  });

  final VehicleConfig config;
  final bool isEnabled;
  final VoidCallback onSelectParts;

  @override
  Widget build(BuildContext context) {
    final parts = config.selectedParts;

    if (parts.isEmpty) {
      return _SelectButton(
        icon: Icons.inventory_2_rounded,
        label: 'Pilih Spare Part / Oli',
        hint: 'Opsional — rekomendasi berdasarkan servis',
        onTap: isEnabled ? onSelectParts : null,
        isDisabled: !isEnabled,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...parts.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: AppColors.success),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${p.name} — ${p.brand}',
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  p.quantity > 1 ? '×${p.quantity}' : '',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  p.subtotal.toCurrency(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Row(
          children: [
            Text(
              '${parts.length} item',
              style: AppTypography.bodySmall,
            ),
            const Spacer(),
            Text(
              'Subtotal: ${config.partsSubtotal.toCurrency()}',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onSelectParts,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                minimumSize: Size.zero,
              ),
              child: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Complaint Section ──────────────────────────────────────────────────────────

class _ComplaintSection extends StatelessWidget {
  const _ComplaintSection({
    required this.isEnabled,
    required this.controller,
    required this.onChanged,
  });

  final bool isEnabled;
  final TextEditingController controller;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: isEnabled,
          maxLines: 4,
          maxLength: 300,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: isEnabled
                ? 'Contoh: Tarikan berat saat pagi hari. Bunyi crek-crek di bagian CVT...'
                : 'Pilih jenis servis terlebih dahulu',
            hintMaxLines: 3,
            alignLabelWithHint: true,
          ),
          style: AppTypography.bodyMedium.copyWith(
            color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xs2),
            Expanded(
              child: Text(
                'Semakin detail keluhanmu, semakin cepat mekanik dapat mendiagnosa.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Config Bottom Bar ──────────────────────────────────────────────────────────

class _ConfigBottomBar extends StatelessWidget {
  const _ConfigBottomBar({
    required this.config,
    required this.session,
    required this.currentIndex,
  });

  final VehicleConfig config;
  final BookingSession session;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final totalVehicles = session.vehicleConfigs.length;
    final hasNext = currentIndex >= 0 && currentIndex < totalVehicles - 1;

    return StickyBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini cost/duration summary
          if (config.isConfigured) ...[
            Container(
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
                  const Icon(Icons.payments_rounded,
                      size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Est. biaya unit ini: ${config.estimatedCost.toCurrency()}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    config.estimatedDuration.toDurationLabel(),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (hasNext) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final nextVehicleId =
                      session.vehicleConfigs[currentIndex + 1].vehicle.id;
                  context.goNamed(
                    RouteConstants.nameVehicleConfig,
                    pathParameters: {
                      RouteConstants.paramVehicleId: nextVehicleId,
                    },
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  config.isConfigured
                      ? 'Simpan & Lanjut ke Unit ${currentIndex + 2}'
                      : 'Lewati & Ke Unit ${currentIndex + 2}',
                ),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeightLg),
                  backgroundColor: config.isConfigured
                      ? AppColors.primary
                      : AppColors.neutral500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(RouteConstants.nameGarage);
                  }
                },
                child: const Text('Simpan & Kembali ke Garasi'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(RouteConstants.nameGarage);
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  config.isConfigured
                      ? 'Simpan & Selesai (Tinjau Garasi)'
                      : 'Kembali ke Garasi',
                ),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeightLg),
                  backgroundColor: config.isConfigured
                      ? AppColors.success
                      : AppColors.neutral400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Select Button ──────────────────────────────────────────────────────────────

class _SelectButton extends StatelessWidget {
  const _SelectButton({
    required this.icon,
    required this.label,
    required this.hint,
    this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md3,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.neutral50 : AppColors.primaryContainer.withValues(alpha: 0.3),
          borderRadius: AppRadius.inputRadius,
          border: Border.all(
            color: isDisabled
                ? AppColors.borderSubtle
                : AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDisabled ? AppColors.neutral300 : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.primary,
                    ),
                  ),
                  Text(
                    hint,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDisabled ? AppColors.neutral300 : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
