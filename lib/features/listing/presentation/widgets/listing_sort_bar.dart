import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: Row(
                  children: [
                    Text(
                      context.l10n.sortBy,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: DropdownButton<SortOption>(
                        value: sort,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        icon: Icon(LucideIcons.chevronDown, color: scheme.onSurfaceVariant),
                        items: SortOption.values
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: Text(ListingSortBar.labelFor(context, o)),
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
          const Gap(AppSpacing.lg),
          _ViewToggleIcon(
            icon: LucideIcons.list,
            selected: viewMode == ViewMode.list,
            onTap: () => onViewModeChanged(ViewMode.list),
          ),
          const Gap(AppSpacing.sm),
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
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(
            icon,
            color: selected ? AppColors.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
