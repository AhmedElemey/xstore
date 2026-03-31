import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
          baseColor: context.isDark
              ? context.surfaceVariantColor.withValues(alpha: 0.55)
              : context.surfaceVariantColor.withValues(alpha: 0.25),
          highlightColor: context.isDark
              ? context.surfaceColor.withValues(alpha: 0.9)
              : context.surfaceColor,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
          ),
        ),
      ),
    );
  }
}
