import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';

class CartVendorBuyersOnly extends StatelessWidget {
  const CartVendorBuyersOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    LucideIcons.shoppingCart,
                    size: AppSpacing.x4l * 2,
                    color: AppColors.textSecondary.withValues(alpha: 0.35),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    top: AppSpacing.sm,
                    child: Icon(
                      LucideIcons.xCircle,
                      size: AppSpacing.x3l,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
              Text(
                AppStrings.cartForBuyersTitle,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.cartForBuyersSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.explore),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                  ),
                  child: Text(AppStrings.cartExploreAsBuyer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
