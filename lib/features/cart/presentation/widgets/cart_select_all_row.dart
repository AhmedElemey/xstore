import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CartSelectAllRow extends ConsumerWidget {
  const CartSelectAllRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(
      cartProvider.select(
        (c) => (
          itemsCount: c.items.length,
          selectedCount: c.selectedItemIds.length,
          total: c.total,
        ),
      ),
    );
    final notifier = ref.read(cartProvider.notifier);
    if (cart.itemsCount == 0) return const SizedBox.shrink();

    bool? boxValue;
    if (cart.itemsCount == 0) {
      boxValue = false;
    } else if (cart.selectedCount == cart.itemsCount) {
      boxValue = true;
    } else if (cart.selectedCount == 0) {
      boxValue = false;
    } else {
      boxValue = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: notifier.toggleSelectAll,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Row(
          children: [
            Checkbox(
              value: boxValue,
              tristate: true,
              onChanged: (_) => notifier.toggleSelectAll(),
            ),
            Expanded(
              child: Text(
                context.l10n.cartSelectAllCount(cart.itemsCount),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
