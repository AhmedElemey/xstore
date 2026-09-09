import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/my_listings_state.dart';

class ListingSortBar extends StatelessWidget {
  const ListingSortBar({
    super.key,
    required this.sort,
    required this.viewMode,
    required this.onSortChanged,
    required this.onViewModeChanged,
  });

  final SortOption sort;
  final ViewMode viewMode;
  final ValueChanged<SortOption> onSortChanged;
  final ValueChanged<ViewMode> onViewModeChanged;

  static String labelFor(BuildContext context, SortOption s) {
    return switch (s) {
      SortOption.newest => context.l10n.sortNewest,
      SortOption.oldest => context.l10n.sortOldest,
      SortOption.priceAsc => context.l10n.sortPriceAsc,
      SortOption.priceDesc => context.l10n.sortPriceDesc,
      SortOption.mostViewed => context.l10n.sortMostViewed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          PopupMenuButton<SortOption>(
            initialValue: sort,
            tooltip: context.l10n.sortBy,
            position: PopupMenuPosition.under,
            padding: EdgeInsets.zero,
            onSelected: onSortChanged,
            itemBuilder: (context) => SortOption.values
                .map(
                  (o) => PopupMenuItem(
                    value: o,
                    child: Text(labelFor(context, o)),
                  ),
                )
                .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.sortBy,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  labelFor(context, sort),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: context.textPrimary,
                ),
              ],
            ),
          ),
          const Spacer(),
          _ViewToggleIcon(
            icon: LucideIcons.list,
            selected: viewMode == ViewMode.list,
            onTap: () => onViewModeChanged(ViewMode.list),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ViewToggleIcon(
            icon: LucideIcons.layoutGrid,
            selected: viewMode == ViewMode.grid,
            onTap: () => onViewModeChanged(ViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleIcon extends StatelessWidget {
  const _ViewToggleIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.12) : scheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            icon,
            size: 18,
            color: selected ? AppColors.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
