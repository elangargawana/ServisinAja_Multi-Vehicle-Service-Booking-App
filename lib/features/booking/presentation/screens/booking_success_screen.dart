// lib/features/booking/presentation/screens/booking_success_screen.dart
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
import 'package:servis_aja/core/utils/booking_id_generator.dart';
import 'package:servis_aja/features/booking/domain/booking.dart';
import 'package:servis_aja/features/booking/domain/booking_session.dart';
import 'package:servis_aja/features/booking/presentation/providers/booking_session_provider.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';

/// Booking success celebration screen.
/// Presents a clear confirmation state with:
/// - Booking number (with quick copy)
/// - Workshop & schedule snapshot
/// - Complete list of vehicles with chosen services, spare parts, and per-vehicle status
/// - Total estimated cost and duration
/// - Direct access to per-vehicle service ticket & tracking
class BookingSuccessScreen extends ConsumerStatefulWidget {
  const BookingSuccessScreen({
    super.key,
    this.session,
    this.booking,
    this.bookingId,
  });

  final BookingSession? session;
  final Booking? booking;
  final String? bookingId;

  @override
  ConsumerState<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends ConsumerState<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late String _bookingId;

  @override
  void initState() {
    super.initState();

    if (widget.booking != null) {
      _bookingId = widget.booking!.id;
    } else if (widget.bookingId != null) {
      _bookingId = widget.bookingId!;
    } else {
      _bookingId = BookingIdGenerator.generate();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Ensure session is saved to repository and draft session reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.booking == null &&
          widget.session != null &&
          widget.session!.hasWorkshopAndSlot) {
        ref.read(bookingDataSourceProvider).createBookingFromSession(
              bookingId: _bookingId,
              session: widget.session!,
            );
        ref.invalidate(userBookingsProvider);
        ref.invalidate(activeBookingsProvider);
      }
      ref.read(bookingSessionProvider.notifier).resetSession();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent accidental back — booking already submitted
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.lg2,
              ),
              children: [
                // ── Success icon animation ─────────────────────
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Title & subtitle ───────────────────────────
                Text(
                  'Booking Berhasil Dikonfirmasi! 🎉',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pesanan servis kamu telah diteruskan ke bengkel mitra. Silakan datang sesuai jadwal yang telah ditentukan.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Booking Confirmation Ticket ────────────────
                _BookingTicket(
                  bookingId: _bookingId,
                  booking: widget.booking,
                  session: widget.session,
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── What's next card ───────────────────────────
                _WhatsNextCard(),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Actions ────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => context.goNamed(
                    RouteConstants.nameTrackingDetail,
                    pathParameters: {
                      RouteConstants.paramBookingId: _bookingId,
                    },
                  ),
                  icon: const Icon(Icons.track_changes_rounded, size: 20),
                  label: const Text('Pantau Status & Tiket Servis'),
                  style: FilledButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, AppSpacing.buttonHeightLg),
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.goNamed(RouteConstants.nameHome),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text('Kembali ke Beranda'),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, AppSpacing.buttonHeightLg),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Booking Ticket ─────────────────────────────────────────────────────────────

class _BookingTicket extends StatelessWidget {
  const _BookingTicket({
    required this.bookingId,
    this.booking,
    this.session,
  });

  final String bookingId;
  final Booking? booking;
  final BookingSession? session;

  @override
  Widget build(BuildContext context) {
    final wsName = booking?.workshopSnapshot.name ??
        session?.selectedWorkshop?.name ??
        'Bengkel Mitra';
    final wsAddress = booking?.workshopSnapshot.address ??
        session?.selectedWorkshop?.address ??
        session?.selectedWorkshop?.district ??
        '';
    final slotDate = booking?.slotSnapshot.date ??
        session?.selectedSlot?.date ??
        '-';
    final slotTime = booking?.slotSnapshot.time ??
        session?.selectedSlot?.time ??
        '-';

    final totalCost = booking?.totalEstimatedCost ??
        session?.totalEstimatedCost ??
        0;
    final totalDuration = booking?.totalEstimatedDuration ??
        session?.totalEstimatedDuration ??
        0;

    final vehicleCount =
        booking?.vehicles.length ?? session?.vehicleConfigs.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardLargeRadius,
        boxShadow: AppShadows.elevation2,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLarge),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOMOR BOOKING / TIKET',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Text(
                        bookingId,
                        style: AppTypography.monoMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Salin Nomor Booking',
                  icon: const Icon(Icons.copy_rounded, color: AppColors.white, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: bookingId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor booking disalin ke clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Workshop & Schedule Details ─────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              children: [
                _TicketRow(
                  icon: Icons.store_rounded,
                  label: 'Bengkel Mitra',
                  value: wsName,
                  sub: wsAddress.isNotEmpty ? wsAddress : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                _TicketRow(
                  icon: Icons.event_rounded,
                  label: 'Jadwal Servis',
                  value: '$slotDate • $slotTime WIB',
                ),
              ],
            ),
          ),

          // ── Dashed Divider ──────────────────────────────────
          _DashedDivider(),

          // ── Daftar Kendaraan & Status Masing-Masing ─────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Daftar Kendaraan',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xs2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '$vehicleCount Unit',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (booking != null) ...[
                  ...booking!.vehicles.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final v = entry.value;
                    return _VehicleTicketItem(
                      index: index,
                      name: v.vehicleSnapshot.displayName,
                      plateNumber: v.vehicleSnapshot.plateNumber,
                      serviceName: v.serviceSnapshot.name,
                      partsText: v.selectedParts.isNotEmpty
                          ? v.selectedParts.map((p) => p.name).join(', ')
                          : null,
                      statusLabel: v.serviceStatus.label,
                      statusColor: v.serviceStatus.color,
                      statusContainerColor: v.serviceStatus.containerColor,
                      cost: v.estimatedCost,
                    );
                  }),
                ] else if (session != null) ...[
                  ...session!.vehicleConfigs.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final cfg = entry.value;
                    return _VehicleTicketItem(
                      index: index,
                      name: cfg.vehicle.displayName,
                      plateNumber: cfg.vehicle.plateNumber,
                      serviceName: cfg.selectedService?.name ?? 'Servis Berkala',
                      partsText: cfg.selectedParts.isNotEmpty
                          ? cfg.selectedParts.map((p) => p.name).join(', ')
                          : null,
                      statusLabel: 'Dikonfirmasi',
                      statusColor: AppColors.success,
                      statusContainerColor: AppColors.successContainer,
                      cost: cfg.estimatedCost,
                    );
                  }),
                ],
              ],
            ),
          ),

          // ── Dashed Divider ──────────────────────────────────
          _DashedDivider(),

          // ── Cost & Duration Summary ─────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Estimasi Total Biaya',
                      style: AppTypography.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      totalCost.toCurrency(),
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (totalDuration > 0) ...[
                  const SizedBox(height: AppSpacing.xs2),
                  Row(
                    children: [
                      Text(
                        'Estimasi Total Durasi Pengerjaan',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '~$totalDuration Menit',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-Vehicle Ticket Item ────────────────────────────────────────────────────

class _VehicleTicketItem extends StatelessWidget {
  const _VehicleTicketItem({
    required this.index,
    required this.name,
    required this.plateNumber,
    required this.serviceName,
    required this.statusLabel,
    required this.statusColor,
    required this.statusContainerColor,
    required this.cost,
    this.partsText,
  });

  final int index;
  final String name;
  final String plateNumber;
  final String serviceName;
  final String? partsText;
  final String statusLabel;
  final Color statusColor;
  final Color statusContainerColor;
  final int cost;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Unit badge + Name + Plate + Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  'Unit $index',
                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusContainerColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 10, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs2),

          // Plate and Service
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  plateNumber,
                  style: AppTypography.monoMedium.copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  serviceName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                cost.toCurrency(),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),

          // Parts if any
          if (partsText != null && partsText!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs2),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    partsText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ── Ticket Row ─────────────────────────────────────────────────────────────────

class _TicketRow extends StatelessWidget {
  const _TicketRow({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary),
              ),
              Text(
                value,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dashed Divider ─────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashPainter(),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    double startX = 0;
    final paint = Paint()
      ..color = AppColors.borderDefault
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── What's Next Card ───────────────────────────────────────────────────────────

class _WhatsNextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: Icons.notifications_active_rounded,
        color: AppColors.info,
        title: 'Notifikasi Konfirmasi',
        desc: 'Bengkel akan memverifikasi kedatangan unit dan jadwal servis kamu.',
      ),
      (
        icon: Icons.directions_car_rounded,
        color: AppColors.primary,
        title: 'Datang Tepat Waktu',
        desc: 'Hadir sesuai jadwal yang dipilih agar proses inspeksi berjalan tepat waktu.',
      ),
      (
        icon: Icons.track_changes_rounded,
        color: AppColors.success,
        title: 'Pantau Status Per-Unit',
        desc: 'Setiap unit kendaraan memiliki alur tracking dan montir masing-masing.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevation1,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Langkah Selanjutnya', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...steps.asMap().entries.map((e) {
            final step = e.value;
            final isLast = e.key == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon, size: 18, color: step.color),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: AppColors.borderSubtle,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : AppSpacing.lg,
                      top: AppSpacing.xs2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title, style: AppTypography.titleSmall),
                        const SizedBox(height: AppSpacing.xs2),
                        Text(
                          step.desc,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
