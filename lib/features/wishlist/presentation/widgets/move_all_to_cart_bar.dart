import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/wishlist_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class MoveAllToCartBar extends ConsumerWidget {
  const MoveAllToCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(
      wishlistProvider.select(
        (s) => (
          total: s.items.length,
          avail: s.items.where((e) => e.isAvailable).length,
          addable: s.items.where((e) => e.isAvailable && !e.isInCart).length,
        ),
      ),
    );
    final total = counts.total;
    final avail = counts.avail;
    final addable = counts.addable;
    if (total == 0 || avail == 0) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      shadowColor: context.textPrimary.withValues(alpha: 0.1),
      color: context.surfaceColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.wishlistItemsAvailableLine(total, avail),
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: addable == 0
                          ? null
                          : () async {
                              final n = addable;
                              await ref
                                  .read(wishlistProvider.notifier)
                                  .moveAllToCart();
                              if (!context.mounted) return;
                              AppSnackbar.show(
                                context,
                                message: context.l10n.wishlistAddedToCartCount(n),
                                action: SnackBarAction(
                                  label: context.l10n.wishlistViewCart,
                                  onPressed: () =>
                                      context.push(AppRoutes.cart),
                                ),
                              );
                            },
                      child: Text(context.l10n.wishlistMoveAllToCart),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Share.share(
                          context.l10n.wishlistShareText(
                            'https://xstore.app/wishlist',
                          ),
                        );
                      },
                      child: Text(context.l10n.wishlistShareWishlist),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
