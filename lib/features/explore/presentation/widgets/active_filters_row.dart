import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../explore_state.dart';

class ActiveFiltersRow extends StatelessWidget {
  const ActiveFiltersRow({
    super.key,
    required this.filters,
    required this.onRemoveCategory,
    required this.onRemoveCondition,
    required this.onClearAll,
    required this.onOpenFilters,
    required this.activeFilterCount,
  });

  final FilterState filters;
  final ValueChanged<String> onRemoveCategory;
  final ValueChanged<String> onRemoveCondition;
  final VoidCallback onClearAll;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final c in filters.categories) {
      chips.add(_FilterChip(
        label: c,
        onRemove: () => onRemoveCategory(c),
      ));
    }
    for (final c in filters.conditions) {
      chips.add(_FilterChip(
        label: c,
        onRemove: () => onRemoveCondition(c),
      ));
    }
    if (filters.minPrice != null || filters.maxPrice != null) {
      chips.add(_FilterChip(
        label: AppStrings.priceRange,
        onRemove: onClearAll,
      ));
    }
    if (filters.minRating != null) {
      chips.add(_FilterChip(
        label: '${filters.minRating}+ ★',
        onRemove: onClearAll,
      ));
    }
    if (filters.location != null && filters.location!.isNotEmpty) {
      chips.add(_FilterChip(
        label: filters.location!,
        onRemove: onClearAll,
      ));
    }
    if (filters.shippingOnly) {
      chips.add(_FilterChip(
        label: AppStrings.shippingOnly,
        onRemove: onClearAll,
      ));
    }

    if (chips.isEmpty && activeFilterCount == 0) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          ActionChip(
            label: Text(AppStrings.addFilters, style: AppTypography.labelLarge),
            onPressed: onOpenFilters,
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (chips.isNotEmpty)
            TextButton.icon(
              onPressed: onClearAll,
              icon: Icon(LucideIcons.x, size: AppSpacing.lg, color: AppColors.primary),
              label: Text(
                AppStrings.clearAllFilters,
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ...chips.map(
            (w) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: w,
            ),
          ),
          ActionChip(
            label: Text(AppStrings.addFilters, style: AppTypography.labelLarge),
            onPressed: onOpenFilters,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTypography.bodySmall),
      deleteIcon: Icon(LucideIcons.x, size: AppSpacing.lg),
      onDeleted: onRemove,
    );
  }
}
