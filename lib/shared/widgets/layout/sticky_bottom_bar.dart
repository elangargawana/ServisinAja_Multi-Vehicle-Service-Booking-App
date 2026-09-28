// lib/shared/widgets/layout/sticky_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_shadows.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';

/// Sticky bottom action bar that respects safe area (home indicator).
/// Used on all screens with a primary CTA.
class StickyBottomBar extends StatelessWidget {
  const StickyBottomBar({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        boxShadow: AppShadows.elevation3,
      ),
      child: Padding(
        padding: (padding ?? const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ))
            .copyWith(bottom: AppSpacing.md + bottomInset),
        child: child,
      ),
    );
  }
}
