import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class MyListingsSkeleton extends StatelessWidget {
  const MyListingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonBox(width: double.infinity, height: 80, borderRadius: 16),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 6,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (_, __) => const SkeletonBox(width: 80, height: 36, borderRadius: 18),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 5,
              separatorBuilder: (_, __) => const Gap(AppSpacing.md),
              itemBuilder: (_, __) => const SkeletonCard(
                child: Row(children: [SkeletonBox(width: 80, height: 80, borderRadius: 10), Gap(AppSpacing.md), Expanded(child: SkeletonLine(height: 14)), SkeletonCircle(size: 24)]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

