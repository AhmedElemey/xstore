import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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

  static String labelFor(SortOption s) {
    return switch (s) {
      SortOption.newest => 'Newest',
      SortOption.oldest => 'Oldest',
      SortOption.priceAsc => 'Price ↑',
      SortOption.priceDesc => 'Price ↓',
      SortOption.mostViewed => 'Most Viewed',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: Row(
                  children: [
                    Text(
                      'Sort by',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: DropdownButton<SortOption>(
                        value: sort,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        icon: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
                        items: SortOption.values
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: Text(ListingSortBar.labelFor(o)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            onSortChanged(v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          _ViewToggleIcon(
            icon: Icons.view_list_rounded,
            selected: viewMode == ViewMode.list,
            onTap: () => onViewModeChanged(ViewMode.list),
          ),
          const Gap(AppSpacing.xs),
          _ViewToggleIcon(
            icon: Icons.grid_view_rounded,
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
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            color: selected ? AppColors.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
