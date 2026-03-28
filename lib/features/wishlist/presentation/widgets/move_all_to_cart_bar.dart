import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/wishlist_provider.dart';

class MoveAllToCartBar extends ConsumerWidget {
  const MoveAllToCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final total = state.items.length;
    final avail = state.items.where((e) => e.isAvailable).length;
    final addable =
        state.items.where((e) => e.isAvailable && !e.isInCart).length;
    if (total == 0 || avail == 0) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.1),
      color: AppColors.cardBg,
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
                AppStrings.wishlistItemsAvailableLine(total, avail),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.wishlistAddedToCartCount(n),
                                  ),
                                  action: SnackBarAction(
                                    label: AppStrings.wishlistViewCart,
                                    onPressed: () =>
                                        context.push(AppRoutes.cart),
                                  ),
                                ),
                              );
                            },
                      child: Text(AppStrings.wishlistMoveAllToCart),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Share.share(
                          AppStrings.wishlistShareText(
                            'https://xstore.app/wishlist',
                          ),
                        );
                      },
                      child: Text(AppStrings.wishlistShareWishlist),
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
