import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: double.infinity, height: 380, borderRadius: 0),
            const Gap(AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: SkeletonBox(width: 56, height: 56, borderRadius: 8),
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(height: 22),
                  Gap(AppSpacing.xs),
                  SkeletonLine(width: 220, height: 22),
                  Gap(AppSpacing.md),
                  SkeletonLine(width: 120, height: 28),
                ],
              ),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonCard(child: Row(children: [SkeletonCircle(size: 48), Gap(AppSpacing.md), Expanded(child: SkeletonLine(width: 180, height: 14)), SkeletonBox(width: 90, height: 34, borderRadius: 8)])),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonLine(width: 160, height: 18),
            ),
            const Gap(AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonLine(height: 13),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

