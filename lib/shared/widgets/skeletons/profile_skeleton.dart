import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(height: 220, color: AppColors.primary.withValues(alpha: 0.3)),
            Transform.translate(
              offset: const Offset(0, -50),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SkeletonCard(
                  child: Column(
                    children: [
                      SkeletonCircle(size: 90),
                      Gap(AppSpacing.md),
                      SkeletonLine(width: 150, height: 20),
                      Gap(AppSpacing.xs),
                      SkeletonLine(width: 200, height: 14),
                    ],
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

