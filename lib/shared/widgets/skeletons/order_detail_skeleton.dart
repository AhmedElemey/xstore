import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const SkeletonBox(width: double.infinity, height: 120, borderRadius: 0),
            const Gap(AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(children: [SkeletonCircle(size: 16), Gap(AppSpacing.md), SkeletonLine(width: 120, height: 13)]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

