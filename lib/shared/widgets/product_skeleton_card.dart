import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/extensions/context_extensions.dart';

class ProductSkeletonCard extends StatelessWidget {
  const ProductSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightBorder;
    final highlight = context.isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.neutral50;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            height: 14,
            width: 120,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(AppSpacing.sm),
          Container(
            height: 12,
            width: 72,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
