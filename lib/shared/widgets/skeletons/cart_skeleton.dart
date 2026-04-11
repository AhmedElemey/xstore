import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonBox(width: double.infinity, height: 44, borderRadius: 12),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 3,
              separatorBuilder: (_, __) => const Gap(AppSpacing.md),
              itemBuilder: (_, __) => const SkeletonCard(child: SkeletonBox(width: double.infinity, height: 140, borderRadius: 12)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonCard(child: SkeletonBox(width: double.infinity, height: 120, borderRadius: 12)),
          ),
        ],
      ),
    );
  }
}

