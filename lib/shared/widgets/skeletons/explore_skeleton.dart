import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class ExploreSkeleton extends StatelessWidget {
  const ExploreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonBox(width: double.infinity, height: 48, borderRadius: 24),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (_, __) => const SkeletonBox(width: 80, height: 32, borderRadius: 16),
            ),
          ),
          const Gap(AppSpacing.md),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(width: 150, height: 14),
                SkeletonBox(width: 80, height: 32, borderRadius: 8),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemBuilder: (_, __) => const SkeletonCard(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: double.infinity, height: 160, borderRadius: 12),
                      Gap(AppSpacing.sm),
                      SkeletonLine(height: 13),
                      Gap(AppSpacing.xs),
                      SkeletonLine(width: 80, height: 13),
                      Gap(AppSpacing.xs),
                      SkeletonLine(width: 70, height: 17),
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

