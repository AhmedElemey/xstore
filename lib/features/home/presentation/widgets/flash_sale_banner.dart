import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class FlashSaleBanner extends StatelessWidget {
  const FlashSaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.accent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.zap, color: AppColors.cardBg),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.flashSaleBannerBody,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.cardBg,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
