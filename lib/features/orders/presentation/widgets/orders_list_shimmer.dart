import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class OrdersListShimmer extends StatelessWidget {
  const OrdersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Shimmer.fromColors(
          baseColor: AppColors.textDisabled.withValues(alpha: 0.25),
          highlightColor: AppColors.cardBg,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
          ),
        ),
      ),
    );
  }
}
