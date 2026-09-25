import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'wishlist_sort_sheet.dart' show wishlistSortLabel;
import '../../../../core/utils/extensions/context_extensions.dart';

/// The filter chips (All/Available/Price Dropped/In Cart) and the sort
/// options (previously a separate "Price Drop ▾" dropdown opening a bottom
/// sheet) share one horizontally scrolling row of chips — filter chips
/// first, then sort chips, each group tracking its own selection.
class WishlistSortRow extends ConsumerWidget {
  const WishlistSortRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      wishlistProvider.select((s) => s.sortOption),
    );
    final selectedFilter = ref.watch(
      wishlistProvider.select((s) => s.selectedFilter),
    );
    final notifier = ref.read(wishlistProvider.notifier);

    return ColoredBox(
      color: context.textDisabled.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: context.l10n.wishlistFilterAll,
                selected: selectedFilter == WishlistFilter.all,
                onTap: () => notifier.applyFilter(WishlistFilter.all),
              ),
              _FilterChip(
                label: context.l10n.wishlistFilterAvailable,
                selected: selectedFilter == WishlistFilter.available,
                onTap: () => notifier.applyFilter(WishlistFilter.available),
              ),
              _FilterChip(
                label: context.l10n.wishlistFilterPriceDropped,
                selected: selectedFilter == WishlistFilter.priceDropped,
                onTap: () =>
                    notifier.applyFilter(WishlistFilter.priceDropped),
              ),
              _FilterChip(
                label: context.l10n.wishlistFilterInCart,
                selected: selectedFilter == WishlistFilter.inCart,
                onTap: () => notifier.applyFilter(WishlistFilter.inCart),
              ),
              for (final o in WishlistSortOption.values)
                _FilterChip(
                  label: wishlistSortLabel(context, o),
                  selected: sortOption == o,
                  onTap: () => notifier.applySort(o),
                ),
            ],
          ),
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
        color: selected ? AppColors.primary : context.surfaceColor,
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
              style: AppTypography.bodySmall.copyWith(
                color: selected ? AppColors.white : context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
