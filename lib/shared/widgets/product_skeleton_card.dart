import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_spacing.dart';

class ProductSkeletonCard extends StatelessWidget {
  const ProductSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: Color.lerp(base, Colors.white, 0.35)!,
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
          const Gap(AppSpacing.sm),
          Container(
            height: 14,
            width: 120,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(AppSpacing.xs),
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
