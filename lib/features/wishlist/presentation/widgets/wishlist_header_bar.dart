import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'wishlist_sort_sheet.dart';

class WishlistHeaderBar extends ConsumerWidget {
  const WishlistHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final notifier = ref.read(wishlistProvider.notifier);
    final n = state.items.length;
    final sel = state.selectedItemIds.length;

    return Material(
      color: AppColors.cardBg,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (n > 0)
              TextButton(
                onPressed: notifier.toggleSelectionMode,
                child: Text(
                  state.isSelectionMode
                      ? AppStrings.wishlistCancelSelect
                      : AppStrings.wishlistSelect,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                state.isSelectionMode
                    ? AppStrings.wishlistSelectedCount(sel)
                    : AppStrings.wishlistAppBarTitle(n),
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: state.viewMode == WishlistViewMode.list
                  ? AppStrings.wishlistGridContentDesc
                  : AppStrings.wishlistListContentDesc,
              onPressed: notifier.toggleViewMode,
              icon: Icon(
                state.viewMode == WishlistViewMode.list
                    ? LucideIcons.layoutGrid
                    : LucideIcons.list,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              tooltip: AppStrings.wishlistSort,
              onPressed: () => showWishlistSortSheet(context, ref),
              icon: const Icon(LucideIcons.arrowUpDown),
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
