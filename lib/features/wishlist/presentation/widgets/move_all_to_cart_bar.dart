import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/wishlist_provider.dart';

/// Orbit wishlist footer: "N in stock · total" and Move all to cart.
class MoveAllToCartBar extends ConsumerWidget {
  const MoveAllToCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(
      wishlistProvider.select((s) {
        var avail = 0;
        var addable = 0;
        var total = 0.0;
        for (final e in s.items) {
          if (!e.isAvailable) continue;
          avail++;
          total += e.price;
          if (!e.isInCart) addable++;
        }
        return (avail: avail, addable: addable, total: total);
      }),
    );
    if (counts.avail == 0) return const SizedBox.shrink();
    final addable = counts.addable;
    final base = AppTypography.bodySmall.copyWith(
      color: context.textSecondary,
    );

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
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${context.l10n.wishlistInStockCount(counts.avail)}'
                        ' · ',
                    children: [
                      TextSpan(
                        text: context.formatCurrency(counts.total),
                        style: base.copyWith(
                          color: context.cashColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  style: base,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              XstoreButton(
                label: context.l10n.wishlistMoveAllToCart,
                onPressed: addable == 0
                    ? null
                    : () async {
                        await ref
                            .read(wishlistProvider.notifier)
                            .moveAllToCart();
                        if (!context.mounted) return;
                        AppSnackbar.show(
                          context,
                          message:
                              context.l10n.wishlistAddedToCartCount(addable),
                          action: SnackBarAction(
                            label: context.l10n.wishlistViewCart,
                            onPressed: () => context.push(AppRoutes.cart),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
