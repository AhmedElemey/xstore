import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

String wishlistSortLabel(WishlistSortOption o) {
  switch (o) {
    case WishlistSortOption.recentlyAdded:
      return AppStrings.wishlistSortRecentlyAdded;
    case WishlistSortOption.priceLowToHigh:
      return AppStrings.wishlistSortPriceLow;
    case WishlistSortOption.priceHighToLow:
      return AppStrings.wishlistSortPriceHigh;
    case WishlistSortOption.priceDrop:
      return AppStrings.wishlistSortPriceDrop;
    case WishlistSortOption.biggestDiscount:
      return AppStrings.wishlistSortBiggestDiscount;
    case WishlistSortOption.nameAZ:
      return AppStrings.wishlistSortNameAz;
  }
}

Future<void> showWishlistSortSheet(BuildContext context, WidgetRef ref) async {
  final current = ref.read(wishlistProvider).sortOption;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                AppStrings.wishlistSort,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final o in WishlistSortOption.values)
              ListTile(
                title: Text(wishlistSortLabel(o)),
                trailing: o == current
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(wishlistProvider.notifier).applySort(o);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      );
    },
  );
}
