import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

/// Orbit product bar: quantity stepper pill and the glowing Add to cart.
/// Buy now lives in the page ([ProductActionsRow]). Seller chat is deferred.
class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.onAddToCart,
    required this.isAddingToCart,
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final VoidCallback onAddToCart;
  final bool isAddingToCart;
  final int quantity;
  final int maxQuantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
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
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                      icon: LucideIcons.minus,
                      tooltip: context.l10n.quantity,
                      onTap: quantity > 1 ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 26,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    _StepButton(
                      icon: LucideIcons.plus,
                      tooltip: context.l10n.quantity,
                      onTap: quantity < maxQuantity ? onIncrement : null,
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: XstoreButton(
                  label: context.l10n.addToCart,
                  isLoading: isAddingToCart,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAddToCart();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      icon: Icon(icon, size: 20),
      color: context.textPrimary,
      disabledColor: context.textDisabled,
      constraints: const BoxConstraints.tightFor(width: 44, height: 52),
    );
  }
}

/// App-only product action the design has no slot for: buy now.
/// Seller chat is parked for the next phase (see the TODO in [build]).
/// Sits under the product header.
class ProductActionsRow extends StatelessWidget {
  const ProductActionsRow({
    super.key,
    required this.onBuyNow,
    required this.stockLeft,
  });

  final VoidCallback onBuyNow;

  /// Shows "Only N left" when stock is low (1–5).
  final int stockLeft;

  @override
  Widget build(BuildContext context) {
    final lowStock = stockLeft > 0 && stockLeft <= 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lowStock) ...[
            Text(
              '${context.l10n.onlyLeftPrefix}$stockLeft${context.l10n.onlyLeftSuffix}',
              style: AppTypography.labelLarge.copyWith(
                color: context.cashColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSpacing.md),
          ],
          Row(
            children: [
              // TODO(phase-2): Seller chat is deferred to the next phase.
              // Restore this button, `onChat`, and `_messageSeller` when
              // in-app chat ships, and include it app-wide (product, store,
              // orders, and the /chat route).
              // OutlinedButton(
              //   onPressed: onChat,
              //   style: OutlinedButton.styleFrom(
              //     shape: const CircleBorder(),
              //     padding: EdgeInsets.zero,
              //     minimumSize: const Size(48, 48),
              //   ),
              //   child: Icon(
              //     LucideIcons.messageCircle,
              //     size: 20,
              //     semanticLabel: context.l10n.chatSeller,
              //   ),
              // ),
              // const Gap(AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBuyNow,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(LucideIcons.zap, size: 18),
                  label: Text(context.l10n.buyNow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
