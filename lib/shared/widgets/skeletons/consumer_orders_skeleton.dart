import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class ConsumerOrdersSkeleton extends StatelessWidget {
  const ConsumerOrdersSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              itemCount: 6,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (_, __) => const SkeletonBox(width: 90, height: 32, borderRadius: 16),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              separatorBuilder: (_, __) => const Gap(AppSpacing.md),
              itemBuilder: (_, __) => const SkeletonCard(child: SkeletonBox(width: double.infinity, height: 170, borderRadius: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

