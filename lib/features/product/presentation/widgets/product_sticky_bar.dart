import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isAddingToCart,
    this.showAddToCart = true,
    this.isSoldOut = false,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isAddingToCart;
  final bool showAddToCart;

  /// Listing has no stock: both purchase buttons are disabled.
  final bool isSoldOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              // The primary action is the gradient pill; "Buy now" steps back
              // to a bordered pill when it shares the bar with "Add to cart".
              if (showAddToCart) ...[
                Expanded(
                  child: _PillButton(
                    filled: true,
                    icon: LucideIcons.shoppingCart,
                    label: isSoldOut
                        ? context.l10n.soldOut
                        : context.l10n.addToCart,
                    isLoading: isAddingToCart,
                    onPressed: isAddingToCart || isSoldOut
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onAddToCart();
                          },
                  ),
                ),
                const Gap(AppSpacing.md),
              ],
              Expanded(
                child: _PillButton(
                  filled: !showAddToCart,
                  icon: LucideIcons.zap,
                  label: context.l10n.buyNow,
                  onPressed: isSoldOut ? null : onBuyNow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 54px pill: brand gradient with a glow when [filled], else a bordered glass
/// pill. The label scales down on narrow screens instead of ellipsizing.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.filled,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool filled;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? context.onBrandColor : context.textPrimary;
    final gradient = context.brandGradient;
    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.45 : 1,
      child: Material(
        color: AppColors.transparent,
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            gradient: filled ? LinearGradient(colors: gradient) : null,
            borderRadius: BorderRadius.circular(27),
            border: filled ? null : Border.all(color: context.borderColor),
            boxShadow: filled && onPressed != null
                ? [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 32,
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 20, color: foreground),
                            const Gap(AppSpacing.sm),
                            Text(
                              label,
                              maxLines: 1,
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
