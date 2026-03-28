import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/wishlist_provider.dart';

class WishlistSelectionBar extends ConsumerWidget {
  const WishlistSelectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    if (!state.isSelectionMode || state.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final sel = state.selectedItemIds.length;
    final addable = state.filteredItems
        .where(
          (e) => state.selectedItemIds.contains(e.id) && e.isAvailable,
        )
        .length;

    return Material(
      elevation: 10,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.12),
      color: AppColors.cardBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        ref.read(wishlistProvider.notifier).selectAllVisible(),
                    child: Text(AppStrings.wishlistSelectAll),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(wishlistProvider.notifier).deselectAll(),
                    child: Text(AppStrings.wishlistDeselectAll),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: sel == 0
                          ? null
                          : () => ref
                              .read(wishlistProvider.notifier)
                              .removeSelected(),
                      child: Text(
                        AppStrings.wishlistRemoveSelectedCount(sel),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: addable == 0
                          ? null
                          : () async {
                              await ref
                                  .read(wishlistProvider.notifier)
                                  .addSelectedToCart();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.wishlistAddedToCartCount(
                                      addable,
                                    ),
                                  ),
                                  action: SnackBarAction(
                                    label: AppStrings.wishlistViewCart,
                                    onPressed: () =>
                                        context.push(AppRoutes.cart),
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        AppStrings.wishlistAddToCartSelected(addable),
                      ),
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
