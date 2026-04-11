import 'package:flutter/material.dart';

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
        VendorOrderSortOption.highestValue => context.l10n.vendorSortHighestValue,
        VendorOrderSortOption.needsAction => context.l10n.vendorSortNeedsAction,
        VendorOrderSortOption.buyerNameAZ => context.l10n.vendorSortBuyerName,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<VendorOrderSortOption>(
              value: sort,
              items: VendorOrderSortOption.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(label(context, e))))
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
          const Spacer(),
          Text(
            context.l10n.ordersCountLine(count),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
