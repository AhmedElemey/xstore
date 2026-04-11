import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class OtpSkeleton extends StatelessWidget {
  const OtpSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWrapper(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Gap(AppSpacing.x4l),
            SkeletonLine(width: 180, height: 20),
            Gap(AppSpacing.md),
            SkeletonLine(width: 220, height: 14),
            Gap(AppSpacing.x2l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 52, height: 56, borderRadius: 12),
                SkeletonBox(width: 52, height: 56, borderRadius: 12),
                SkeletonBox(width: 52, height: 56, borderRadius: 12),
                SkeletonBox(width: 52, height: 56, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

