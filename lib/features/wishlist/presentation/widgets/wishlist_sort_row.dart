import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'wishlist_sort_sheet.dart';

class WishlistSortRow extends ConsumerWidget {
  const WishlistSortRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final notifier = ref.read(wishlistProvider.notifier);

    return ColoredBox(
      color: AppColors.textDisabled.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => showWishlistSortSheet(context, ref),
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                  border: Border.all(
                    color: AppColors.textDisabled.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      wishlistSortLabel(state.sortOption),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: AppSpacing.x2l,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: AppStrings.wishlistFilterAll,
                      selected: state.selectedFilter == WishlistFilter.all,
                      onTap: () => notifier.applyFilter(WishlistFilter.all),
                    ),
                    _FilterChip(
                      label: AppStrings.wishlistFilterAvailable,
                      selected: state.selectedFilter == WishlistFilter.available,
                      onTap: () => notifier.applyFilter(WishlistFilter.available),
                    ),
                    _FilterChip(
                      label: AppStrings.wishlistFilterPriceDropped,
                      selected:
                          state.selectedFilter == WishlistFilter.priceDropped,
                      onTap: () =>
                          notifier.applyFilter(WishlistFilter.priceDropped),
                    ),
                    _FilterChip(
                      label: AppStrings.wishlistFilterInCart,
                      selected: state.selectedFilter == WishlistFilter.inCart,
                      onTap: () => notifier.applyFilter(WishlistFilter.inCart),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.primary : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
