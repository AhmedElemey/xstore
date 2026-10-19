import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/listing_entity.dart';

class ListingFilterTabs extends StatelessWidget {
  const ListingFilterTabs({
    super.key,
    required this.selected,
    required this.onFilterSelected,
  });

  /// `null` selects “All”.
  final ListingStatus? selected;
  final ValueChanged<ListingStatus?> onFilterSelected;

  static const _statuses = <ListingStatus?>[
    null,
    ListingStatus.active,
    ListingStatus.pending,
    ListingStatus.paused,
    ListingStatus.sold,
    ListingStatus.rejected,
  ];

  static String _label(BuildContext context, ListingStatus? s) => switch (s) {
    null => context.l10n.ordersFilterAll,
    ListingStatus.active => context.l10n.active,
    ListingStatus.pending => context.l10n.pending,
    ListingStatus.paused => context.l10n.paused,
    ListingStatus.sold => context.l10n.sold,
    ListingStatus.rejected => context.l10n.rejected,
    ListingStatus.draft => context.l10n.draft,
  };

  @override
  Widget build(BuildContext context) {
    // Orbit segmented bar: a frosted capsule holding scrollable pills.
    return Container(
      height: 46,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(4),
        itemCount: _statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, i) => _FilterChipPill(
          label: _label(context, _statuses[i]),
          selected: selected == _statuses[i],
          onTap: () => onFilterSelected(_statuses[i]),
        ),
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
    final selectedBg = context.isDark ? context.textPrimary : AppColors.primary;
    final selectedFg = context.isDark ? AppColors.darkOnBrand : AppColors.white;
    return Material(
      color: selected ? selectedBg : AppColors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? selectedFg : context.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
