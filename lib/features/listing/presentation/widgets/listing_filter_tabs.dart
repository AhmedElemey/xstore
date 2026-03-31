import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ListingFilterTabs extends StatelessWidget {
  const ListingFilterTabs({
    super.key,
    required this.selected,
    required this.onFilterSelected,
  });

  /// `null` selects “All”.
  final ListingStatus? selected;
  final ValueChanged<ListingStatus?> onFilterSelected;

  static const _chips = <({String label, ListingStatus? status})>[
    (label: 'All', status: null),
    (label: 'Active', status: ListingStatus.active),
    (label: 'Pending', status: ListingStatus.pending),
    (label: 'Paused', status: ListingStatus.paused),
    (label: 'Sold', status: ListingStatus.sold),
    (label: 'Rejected', status: ListingStatus.rejected),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final c in _chips) ...[
            _FilterChipPill(
              label: c.label,
              selected: selected == c.status,
              onTap: () => onFilterSelected(c.status),
            ),
            const Gap(AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outline = context.borderColor.withValues(alpha: 0.8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : context.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primary : outline,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
