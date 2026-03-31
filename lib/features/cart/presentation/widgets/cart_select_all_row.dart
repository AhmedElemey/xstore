import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Checkbox(
                value: boxValue,
                tristate: true,
                onChanged: (_) => notifier.toggleSelectAll(),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  AppStrings.cartSelectAllCount(cart.itemsCount),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${AppStrings.cartTotalLabel}: ${Formatters.dzdWhole(cart.total)}',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
