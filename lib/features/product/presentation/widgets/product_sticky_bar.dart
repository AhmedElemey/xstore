import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.onChat,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isAddingToCart,
    this.showAddToCart = true,
  });

  final VoidCallback onChat;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isAddingToCart;
  final bool showAddToCart;

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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  minimumSize: const Size(AppSpacing.x3l + AppSpacing.md, AppSpacing.x3l + AppSpacing.md),
                ),
                child: const Icon(LucideIcons.messageCircle, size: 22),
              ),
              const Gap(AppSpacing.md),
              if (showAddToCart) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: isAddingToCart ? null : onAddToCart,
                    child: isAddingToCart
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.surfaceColor,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.shoppingCart, size: 20),
                              const Gap(AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  AppStrings.addToCart,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const Gap(AppSpacing.md),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: onBuyNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: context.surfaceColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.zap, size: 20),
                      const Gap(AppSpacing.sm),
                      Flexible(
                        child: Text(
                          AppStrings.buyNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
