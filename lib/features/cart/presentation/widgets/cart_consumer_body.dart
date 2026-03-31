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
import '../../../../core/utils/extensions/context_extensions.dart';

class CartConsumerBody extends ConsumerWidget {
  const CartConsumerBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(cartProvider.select((c) => c.isLoading));
    final items = ref.watch(cartProvider.select((c) => c.items));
    final groups = ref.watch(cartProvider.select((c) => c.vendorGroups));
    final error = ref.watch(cartProvider.select((c) => c.error));

    if (isLoading && items.isEmpty) {
      return ColoredBox(
        color: context.backgroundColor,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return const CartEmptyState();
    }
    final childCount = groups.length + 7;

    return ColoredBox(
      color: context.backgroundColor,
      child: Column(
        children: [
          if (error != null)
            Material(
              color: AppColors.error.withValues(alpha: 0.12),
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: AppColors.error),
                title: Text(
                  error,
                  style: TextStyle(color: AppColors.error),
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
              cacheExtent: 1000,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) return const CartSelectAllRow();
                        if (index <= groups.length) {
                          final group = groups[index - 1];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: RepaintBoundary(
                              child: CartVendorGroupBlock(
                                key: ValueKey<String>(
                                  'cart-vendor-${group.vendorId}',
                                ),
                                group: group,
                              ),
                            ),
                          );
                        }
                        final tail = index - (groups.length + 1);
                        switch (tail) {
                          case 0:
                            return const CouponInputRow();
                          case 1:
                            return const Gap(AppSpacing.lg);
                          case 2:
                            return const CartSummaryCard();
                          case 3:
                            return const Gap(AppSpacing.x2l);
                          case 4:
                            return const CartRecommendedStrip();
                          case 5:
                            return const Gap(AppSpacing.x4l);
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                      childCount: childCount,
                    ),
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
