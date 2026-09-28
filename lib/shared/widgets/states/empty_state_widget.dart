// lib/shared/widgets/states/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';

/// Generic empty state widget with icon, title, subtitle and optional CTA.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final iColor = iconColor ?? AppColors.primary;
    final iBgColor = iconBackgroundColor ?? AppColors.primaryContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: iBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iColor),
            ),
            const SizedBox(height: AppSpacing.lg2),

            // Title
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],

            // CTA
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialised empty state for the user's vehicle garage.
class EmptyGarageState extends StatelessWidget {
  const EmptyGarageState({super.key, required this.onAddVehicle});
  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.garage_rounded,
      title: 'Garasi masih kosong',
      subtitle:
          'Tambahkan kendaraanmu terlebih dahulu untuk mulai booking servis.',
      actionLabel: 'Tambah Kendaraan',
      onAction: onAddVehicle,
    );
  }
}
