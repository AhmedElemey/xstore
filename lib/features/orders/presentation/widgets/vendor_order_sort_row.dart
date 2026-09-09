import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/vendor_orders_provider.dart';

class VendorOrderSortRow extends StatelessWidget {
  const VendorOrderSortRow({
    super.key,
    required this.sort,
    required this.count,
    required this.onChanged,
  });

  final VendorOrderSortOption sort;
  final int count;
  final ValueChanged<VendorOrderSortOption> onChanged;

  static String label(BuildContext context, VendorOrderSortOption value) =>
      switch (value) {
        VendorOrderSortOption.newestFirst => context.l10n.vendorSortNewestFirst,
        VendorOrderSortOption.oldestFirst => context.l10n.vendorSortOldestFirst,
        VendorOrderSortOption.highestValue =>
          context.l10n.vendorSortHighestValue,
        VendorOrderSortOption.needsAction => context.l10n.vendorSortNeedsAction,
        VendorOrderSortOption.buyerNameAZ => context.l10n.vendorSortBuyerName,
      };

  @override
  Widget build(BuildContext context) {
    final needsAction = sort == VendorOrderSortOption.needsAction;
    final accent = needsAction ? AppColors.warning : context.textPrimary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          PopupMenuButton<VendorOrderSortOption>(
            initialValue: sort,
            tooltip: context.l10n.sortBy,
            position: PopupMenuPosition.under,
            padding: EdgeInsets.zero,
            onSelected: onChanged,
            itemBuilder: (context) => VendorOrderSortOption.values
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(label(context, e)),
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
                  label(context, sort),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: accent,
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            context.l10n.ordersCountLine(count),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
