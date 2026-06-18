import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

class WishlistVendorGuard extends StatelessWidget {
  const WishlistVendorGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.backgroundColor,
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
                    LucideIcons.heart,
                    size: AppSpacing.x4l * 2,
                    color: context.textSecondary.withValues(alpha: 0.35),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    top: AppSpacing.sm,
                    child: Icon(
                      LucideIcons.x,
                      size: AppSpacing.x3l,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
              Text(
                context.l10n.wishlistForBuyersTitle,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.wishlistForBuyersSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.wishlistExploreAsBuyer,
                onPressed: () => context.go(AppRoutes.explore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
