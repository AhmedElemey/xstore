import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'wishlist_sort_sheet.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Toolbar under [WishlistSortRow]: Select + list/grid + sort.
///
/// Hidden for now — kept in source so it can be restored by uncommenting
/// `WishlistHeaderBar` in [WishlistConsumerBody].
class WishlistHeaderBar extends ConsumerWidget {
  const WishlistHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      wishlistProvider.select(
        (s) => (
          itemCount: s.items.length,
          isSelectionMode: s.isSelectionMode,
          viewMode: s.viewMode,
        ),
      ),
    );
    final notifier = ref.read(wishlistProvider.notifier);
    final n = state.itemCount;

    if (n == 0) {
      return const SizedBox.shrink();
    }

    return Material(
      color: context.surfaceColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: notifier.toggleSelectionMode,
              child: Text(
                state.isSelectionMode
                    ? context.l10n.wishlistCancelSelect
                    : context.l10n.wishlistSelect,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: state.viewMode == WishlistViewMode.list
                  ? context.l10n.wishlistGridContentDesc
                  : context.l10n.wishlistListContentDesc,
              onPressed: notifier.toggleViewMode,
              icon: Icon(
                state.viewMode == WishlistViewMode.list
                    ? LucideIcons.layoutGrid
                    : LucideIcons.list,
                color: context.textPrimary,
              ),
            ),
            IconButton(
              tooltip: context.l10n.wishlistSort,
              onPressed: () => showWishlistSortSheet(context, ref),
              icon: const Icon(LucideIcons.arrowUpDown),
              color: context.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
