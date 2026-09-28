// lib/features/booking/presentation/screens/booking_review_screen.dart
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
import 'package:servis_aja/core/utils/booking_id_generator.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';

/// Full booking summary before submission.
/// User reviews everything: workshop, schedule, per-vehicle config, totals.
/// Can edit each section without losing other data.
class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key});

  @override
  ConsumerState<BookingReviewScreen> createState() =>
      _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(bookingSessionProvider);

    // Guard: session must be complete before showing review
    final errors = _validateSession(session);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ringkasan Booking'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteConstants.nameSchedule);
            }
          },
        ),
        actions: [
          // Indicator: all checks pass
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: errors.isEmpty
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 22)
                  : Badge(
                      label: Text('${errors.length}'),
                      backgroundColor: AppColors.error,
                      child: const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 22),
                    ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.md,
        ),
        children: [
          // ── 1. Workshop & Schedule ──────────────────────────
          _WorkshopScheduleCard(
            session: session,
            onEditWorkshop: () =>
                context.goNamed(RouteConstants.nameWorkshopList),
            onEditSchedule: () =>
                context.goNamed(RouteConstants.nameSchedule),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── 2. Vehicles header ──────────────────────────────
          Row(
            children: [
              Text(
                '${session.vehicleConfigs.length} Kendaraan',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '— konfigurasi masing-masing',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionHeaderGap),

          // ── 3. Per-vehicle cards ────────────────────────────
          ...session.vehicleConfigs.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: _VehicleReviewCard(
                    index: e.key + 1,
                    config: e.value,
                    onEdit: () => context.goNamed(
                      RouteConstants.nameVehicleConfig,
                      pathParameters: {
                        RouteConstants.paramVehicleId:
                            e.value.vehicle.id,
                      },
                    ),
                  ),
                ),
              ),

          // ── 4. Validation errors ────────────────────────────
          if (errors.isNotEmpty) ...[
            _ValidationErrorBanner(errors: errors),
            const SizedBox(height: AppSpacing.cardGap),
          ],

          // ── 5. Cost summary ─────────────────────────────────
          _CostSummaryCard(session: session),
          const SizedBox(height: AppSpacing.cardGap),

          // ── 6. Terms agreement ──────────────────────────────
          _TermsCheckbox(
            agreed: _agreeToTerms,
            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          ),

          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: StickyBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error summary above button
            if (errors.isNotEmpty || !_agreeToTerms) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Text(
                  _bottomHintText(errors),
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSubmit(errors)
                    ? () => _handleSubmit(context, session)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeightLg),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text('Konfirmasi Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  List<String> _validateSession(BookingSession session) {
    final errors = <String>[];

    if (session.selectedWorkshop == null) {
      errors.add('Bengkel belum dipilih.');
    }
    if (session.selectedSlot == null) {
      errors.add('Jadwal belum dipilih.');
    }
    if (session.vehicleConfigs.isEmpty) {
      errors.add('Minimal satu kendaraan harus ditambahkan.');
    }
    final unconfigured = session.vehicleConfigs
        .where((c) => !c.isConfigured)
        .map((c) => c.vehicle.displayName)
        .toList();
    if (unconfigured.isNotEmpty) {
      errors.add(
        '${unconfigured.join(", ")} belum dikonfigurasi.',
      );
    }
    return errors;
  }

  bool _canSubmit(List<String> errors) =>
      errors.isEmpty && _agreeToTerms && !_isSubmitting;

  String _bottomHintText(List<String> errors) {
    if (errors.isNotEmpty) return errors.first;
    if (!_agreeToTerms) return 'Setujui syarat & ketentuan untuk melanjutkan.';
    return '';
  }

  Future<void> _handleSubmit(
      BuildContext context, BookingSession session) async {
    setState(() => _isSubmitting = true);

    // Capture navigator before async gap (lint: use_build_context_synchronously)
    final router = GoRouter.of(context);
    final bookingId = BookingIdGenerator.generate();

    // Register booking in data source
    final createdBooking =
        ref.read(bookingDataSourceProvider).createBookingFromSession(
              bookingId: bookingId,
              session: session,
            );
    ref.invalidate(userBookingsProvider);
    ref.invalidate(activeBookingsProvider);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    router.goNamed(
      RouteConstants.nameBookingSuccess,
      extra: createdBooking,
    );
  }
}

// ── Workshop & Schedule Card ───────────────────────────────────────────────────

class _WorkshopScheduleCard extends StatelessWidget {
  const _WorkshopScheduleCard({
    required this.session,
    required this.onEditWorkshop,
    required this.onEditSchedule,
  });

  final BookingSession session;
  final VoidCallback onEditWorkshop;
  final VoidCallback onEditSchedule;

  @override
  Widget build(BuildContext context) {
    final ws = session.selectedWorkshop;
    final slot = session.selectedSlot;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
        border: Border.all(
          color: (ws == null || slot == null)
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Bengkel & Jadwal',
                    style: AppTypography.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),

          // Workshop row
          _ReviewRow(
            icon: Icons.handyman_rounded,
            label: 'Bengkel',
            value: ws?.name ?? 'Belum dipilih',
            valueColor: ws == null ? AppColors.error : null,
            secondaryValue: ws != null
                ? '${ws.district}, ${ws.city}'
                : null,
            onEdit: onEditWorkshop,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Schedule row
          _ReviewRow(
            icon: Icons.event_rounded,
            label: 'Jadwal',
            value: slot != null
                ? '${slot.date} • ${slot.time}'
                : 'Belum dipilih',
            valueColor: slot == null ? AppColors.error : null,
            onEdit: onEditSchedule,
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Review Card ────────────────────────────────────────────────────────

class _VehicleReviewCard extends StatelessWidget {
  const _VehicleReviewCard({
    required this.index,
    required this.config,
    required this.onEdit,
  });

  final int index;
  final VehicleConfig config;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final vehicle = config.vehicle;
    final service = config.selectedService;
    final parts = config.selectedParts;
    final complaint = config.complaintText.trim();
    final isConfigured = config.isConfigured;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
        border: Border.all(
          color: isConfigured
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vehicle header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isConfigured
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTypography.labelSmall.copyWith(
                        color: isConfigured
                            ? AppColors.successDark
                            : AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  vehicle.isMotor
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.displayName,
                          style: AppTypography.titleSmall),
                      Text(
                        vehicle.plateNumber,
                        style: AppTypography.monoMedium.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Edit button
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          if (!isConfigured) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Belum dikonfigurasi — ketuk Edit',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textWarning,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Divider(height: 1),

            // Service
            _DetailRow(
              icon: Icons.build_rounded,
              label: 'Jenis Servis',
              value: service?.name ?? '-',
              badge: service != null
                  ? config.estimatedDuration.toDurationLabel()
                  : null,
            ),

            // Spare parts
            if (parts.isNotEmpty) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Spare Part & Oli (${parts.length} item)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...parts.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.xs2, left: AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${p.name} — ${p.brand}',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                            if (p.quantity > 1)
                              Text(
                                '×${p.quantity}  ',
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.textTertiary),
                              ),
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
                  ],
                ),
              ),
            ],

            // Complaint
            if (complaint.isNotEmpty) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              _DetailRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Keluhan',
                value: complaint,
                valueMaxLines: 3,
              ),
            ],

            // Cost per vehicle
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Estimasi biaya kendaraan ini',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const Spacer(),
                  Text(
                    config.estimatedCost.toCurrency(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Cost Summary Card ──────────────────────────────────────────────────────────

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.session});
  final BookingSession session;

  @override
  Widget build(BuildContext context) {
    final total = session.totalEstimatedCost;
    final duration = session.totalEstimatedDuration;
    final vehicleCount = session.vehicleConfigs.length;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation2,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Estimasi',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      total.toCurrency(),
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'untuk $vehicleCount kendaraan',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded,
                          color: AppColors.white, size: 16),
                      const SizedBox(width: AppSpacing.xs2),
                      Text(
                        duration.toDurationLabel(),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'total durasi',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.cardRadius,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.white),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Biaya final dikonfirmasi oleh bengkel setelah diagnosa kendaraan.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Terms Checkbox ─────────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onChanged});
  final bool agreed;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: agreed ? AppColors.borderBrand : AppColors.borderDefault,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!agreed),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs2),
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              'Saya menyetujui estimasi biaya dan durasi bersifat perkiraan. '),
                      TextSpan(
                        text: 'Syarat & Ketentuan',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' berlaku.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Row Widgets ─────────────────────────────────────────────────────────

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.secondaryValue,
    this.valueColor,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? secondaryValue;
  final Color? valueColor;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
                Text(
                  value,
                  style: AppTypography.titleSmall.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                if (secondaryValue != null)
                  Text(secondaryValue!,
                      style: AppTypography.bodySmall),
              ],
            ),
          ),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Ganti'),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    this.valueMaxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? badge;
  final int valueMaxLines;

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
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
                Text(
                  value,
                  style: AppTypography.bodyMedium,
                  maxLines: valueMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.r4),
              ),
              child: Text(
                badge!,
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.primaryDark),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Validation Error Banner ────────────────────────────────────────────────────

class _ValidationErrorBanner extends StatelessWidget {
  const _ValidationErrorBanner({required this.errors});
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Lengkapi sebelum booking',
                style: AppTypography.titleSmall
                    .copyWith(color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ...errors.map(
            (e) => Padding(
              padding: const EdgeInsets.only(
                  left: AppSpacing.lg, bottom: AppSpacing.xs2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.error)),
                  Expanded(
                    child: Text(
                      e,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
