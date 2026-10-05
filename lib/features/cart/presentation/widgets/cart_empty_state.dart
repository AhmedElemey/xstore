import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.glassColor,
                  border: Border.all(color: context.borderColor),
                ),
                child: SizedBox.square(
                  dimension: 120,
                  child: Icon(
                    LucideIcons.shoppingCart,
                    size: 52,
                    color: context.linkColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              context.l10n.cartEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            XstoreButton(
              label: context.l10n.cartStartShopping,
              onPressed: () => context.go(AppRoutes.explore),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.wishlist),
              child: Text(
                context.l10n.cartOrWishlist,
                style: AppTypography.labelLarge.copyWith(
                  color: context.linkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
