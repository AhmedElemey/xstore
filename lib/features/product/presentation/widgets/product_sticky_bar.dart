import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.onChat,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isAddingToCart,
    this.showAddToCart = true,
    this.isSoldOut = false,
  });

  final VoidCallback onChat;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isAddingToCart;
  final bool showAddToCart;

  /// Listing has no stock: both purchase buttons are disabled.
  final bool isSoldOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 12,
      shadowColor: context.textPrimary.withValues(alpha: 0.12),
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onChat,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  minimumSize: const Size(
                    AppSpacing.x3l + AppSpacing.md,
                    AppSpacing.x3l + AppSpacing.md,
                  ),
                ),
                child: const Icon(LucideIcons.messageCircle, size: 22),
              ),
              const Gap(AppSpacing.md),
              if (showAddToCart) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: isAddingToCart || isSoldOut
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onAddToCart();
                          },
                    child: isAddingToCart
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.surfaceColor,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.shoppingCart, size: 20),
                                const Gap(AppSpacing.sm),
                                Text(
                                  isSoldOut
                                      ? context.l10n.soldOut
                                      : context.l10n.addToCart,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const Gap(AppSpacing.md),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: isSoldOut ? null : onBuyNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: context.surfaceColor,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.zap, size: 20),
                        const Gap(AppSpacing.sm),
                        Text(context.l10n.buyNow, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
