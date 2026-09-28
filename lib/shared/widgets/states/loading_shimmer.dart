// lib/shared/widgets/states/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';

/// Base shimmer widget. Wrap any placeholder widget with this.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: child,
    );
  }
}

/// Shimmer placeholder shaped like a rectangular card.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.radius,
  });

  final double height;
  final double width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(radius ?? AppRadius.card),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a text line.
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    this.width = 120,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(AppRadius.r4),
        ),
      ),
    );
  }
}
