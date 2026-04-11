import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class VendorOrdersSkeleton extends StatelessWidget {
  const VendorOrdersSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonBox(width: double.infinity, height: 90, borderRadius: 20),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 7,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (_, __) => const SkeletonBox(width: 90, height: 32, borderRadius: 16),
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              separatorBuilder: (_, __) => const Gap(AppSpacing.md),
              itemBuilder: (_, __) => const SkeletonCard(child: SkeletonBox(width: double.infinity, height: 180, borderRadius: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

