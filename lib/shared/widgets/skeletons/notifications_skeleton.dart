import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (_, __) => const SkeletonBox(width: 80, height: 32, borderRadius: 16),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    SkeletonCircle(size: 40),
                    Gap(AppSpacing.md),
                    Expanded(child: SkeletonLine(height: 14)),
                    Gap(AppSpacing.md),
                    SkeletonBox(width: 48, height: 48, borderRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

