import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/cart_provider.dart';
import 'cart_checkout_bar.dart';
import 'cart_empty_state.dart';
import 'cart_recommended_strip.dart';
import 'cart_select_all_row.dart';
import 'cart_summary_card.dart';
import 'cart_vendor_group.dart';
import 'coupon_input_row.dart';

class CartConsumerBody extends ConsumerWidget {
  const CartConsumerBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.isLoading && cart.items.isEmpty) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cart.items.isEmpty) {
      return const CartEmptyState();
    }

    final groups = cart.vendorGroups;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          if (cart.error != null)
            Material(
              color: AppColors.error.withValues(alpha: 0.12),
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: AppColors.error),
                title: Text(
                  cart.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).clearError(),
                ),
              ),
            ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const CartSelectAllRow(),
                      ...groups.map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: CartVendorGroupBlock(group: g),
                        ),
                      ),
                      const CouponInputRow(),
                      const Gap(AppSpacing.lg),
                      const CartSummaryCard(),
                      const Gap(AppSpacing.x2l),
                      const CartRecommendedStrip(),
                      const Gap(AppSpacing.x4l),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          const CartCheckoutBar(),
        ],
      ),
    );
  }
}
