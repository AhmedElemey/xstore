import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_spacing.dart';
import 'skeleton_base.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: const [
                  SkeletonBox(width: 80, height: 28, borderRadius: 6),
                  Gap(AppSpacing.md),
                  Expanded(child: SkeletonBox(width: double.infinity, height: 44, borderRadius: 22)),
                  Gap(AppSpacing.md),
                  SkeletonCircle(size: 36),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SkeletonBox(width: 90, height: 28, borderRadius: 14),
                  SkeletonBox(width: 90, height: 28, borderRadius: 14),
                  SkeletonBox(width: 90, height: 28, borderRadius: 14),
                ],
              ),
            ),
            const Gap(AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonBox(width: double.infinity, height: 180, borderRadius: 16),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonLine(width: 140, height: 18),
            ),
            const Gap(AppSpacing.md),
            SizedBox(
              height: 80,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                itemBuilder: (_, __) => const Column(
                  children: [
                    SkeletonCircle(size: 52),
                    Gap(AppSpacing.xs),
                    SkeletonLine(width: 48, height: 10),
                  ],
                ),
              ),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkeletonBox(width: double.infinity, height: 64, borderRadius: 16),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLine(width: 120, height: 18),
                  SkeletonLine(width: 60, height: 14),
                ],
              ),
            ),
            const Gap(AppSpacing.md),
            SizedBox(
              height: 220,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                itemBuilder: (_, __) => const _Card150Skeleton(),
              ),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(child: SkeletonBox(width: double.infinity, height: 160, borderRadius: 16)),
                  Gap(AppSpacing.md),
                  Expanded(child: SkeletonBox(width: double.infinity, height: 160, borderRadius: 16)),
                ],
              ),
            ),
            const Gap(AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [SkeletonLine(width: 130, height: 18), SkeletonLine(width: 60, height: 14)],
              ),
            ),
            const Gap(AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemBuilder: (_, __) => const _GridCardSkeleton(),
              ),
            ),
            const Gap(AppSpacing.x3l),
          ],
        ),
      ),
    );
  }
}

class _Card150Skeleton extends StatelessWidget {
  const _Card150Skeleton();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 150,
      child: SkeletonCard(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 150, height: 140, borderRadius: 12),
            Gap(AppSpacing.sm),
            SkeletonLine(height: 12),
            Gap(AppSpacing.xs),
            SkeletonLine(width: 80, height: 16),
          ],
        ),
      ),
    );
  }
}

class _GridCardSkeleton extends StatelessWidget {
  const _GridCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 160, borderRadius: 12),
          Gap(AppSpacing.sm),
          SkeletonLine(height: 13),
          Gap(AppSpacing.xs),
          SkeletonLine(width: 90, height: 13),
          Gap(AppSpacing.xs),
          SkeletonLine(width: 70, height: 17),
        ],
      ),
    );
  }
}

