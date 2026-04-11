import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class EditProfileSkeleton extends StatelessWidget {
  const EditProfileSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: SkeletonCircle(size: 100)),
            Gap(AppSpacing.xl),
            SkeletonLine(width: 130, height: 12),
            Gap(AppSpacing.md),
            SkeletonBox(width: double.infinity, height: 52, borderRadius: 12),
            Gap(AppSpacing.md),
            SkeletonBox(width: double.infinity, height: 52, borderRadius: 12),
            Gap(AppSpacing.md),
            SkeletonBox(width: double.infinity, height: 52, borderRadius: 12),
            Gap(AppSpacing.md),
            SkeletonBox(width: double.infinity, height: 52, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

