import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Status chips with counts ("Active · 10"); the selected one is amber.
class ListingFilterTabs extends StatelessWidget {
  const ListingFilterTabs({
    super.key,
    required this.selected,
    required this.total,
    required this.counts,
    required this.onFilterSelected,
  });

  /// `null` selects “All”.
  final ListingStatus? selected;
  final int total;
  final Map<ListingStatus, int> counts;
  final ValueChanged<ListingStatus?> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <(String, ListingStatus?)>[
      (l10n.myListingsFilterAll, null),
      (l10n.active, ListingStatus.active),
      (l10n.pending, ListingStatus.pending),
      (l10n.paused, ListingStatus.paused),
      (l10n.sold, ListingStatus.sold),
      (l10n.rejected, ListingStatus.rejected),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final (label, status) in chips) ...[
            _FilterChipPill(
              label: '$label · ${status == null ? total : counts[status] ?? 0}',
              selected: selected == status,
              onTap: () => onFilterSelected(status),
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
    final warm = context.cashColor;
    return Material(
      color: selected ? warm : glassFill(context),
      shape: StadiumBorder(
        side: BorderSide(color: selected ? warm : context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? const Color(0xFF140A04) : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
