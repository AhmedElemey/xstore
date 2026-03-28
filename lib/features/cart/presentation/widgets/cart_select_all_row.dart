import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';

class CartSelectAllRow extends ConsumerWidget {
  const CartSelectAllRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    if (cart.items.isEmpty) return const SizedBox.shrink();

    bool? boxValue;
    if (cart.items.isEmpty) {
      boxValue = false;
    } else if (cart.selectedItemIds.length == cart.items.length) {
      boxValue = true;
    } else if (cart.selectedItemIds.isEmpty) {
      boxValue = false;
    } else {
      boxValue = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.cardBg,
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
                  AppStrings.cartSelectAllCount(cart.items.length),
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
