import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class StoreHoursSkeleton extends StatelessWidget {
  const StoreHoursSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SkeletonBox(width: double.infinity, height: 110, borderRadius: 16),
            const Gap(AppSpacing.xl),
            ...List.generate(
              7,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonCard(child: SkeletonBox(width: double.infinity, height: 80, borderRadius: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

