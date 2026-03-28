import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.onChat,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isAddingToCart,
  });

  final VoidCallback onChat;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isAddingToCart;

  static const _accentOrange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 12,
      shadowColor: Colors.black26,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onChat,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: isAddingToCart ? null : onAddToCart,
                  child: isAddingToCart
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 20),
                            const Gap(AppSpacing.xs),
                            Flexible(
                              child: Text(
                                'Add to Cart',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onBuyNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 20),
                      const Gap(AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Buy Now',
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
