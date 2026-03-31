import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import 'cart_summary_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CheckoutReviewSection extends ConsumerWidget {
  const CheckoutReviewSection({super.key});

  static String _payLabel(PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => AppStrings.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => AppStrings.ordersPaymentCib,
        PaymentMethod.dahabiCard => AppStrings.ordersPaymentDahabi,
        PaymentMethod.baridimob => AppStrings.ordersPaymentBaridimob,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final st = ref.watch(checkoutProvider);
    final items = cart.selectedAvailableItems.toList();
    final idx = st.selectedAddressIndex;
    final addr = idx != null &&
            idx >= 0 &&
            idx < st.savedAddresses.length
        ? st.savedAddresses[idx]
        : null;
    final pay = st.selectedPayment;
    final vendors = items.map((e) => e.vendorId).toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.checkoutReviewTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.checkoutItemsFromSellers(items.length, vendors),
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  child: SizedBox(
                    width: AppSpacing.x3l + AppSpacing.sm,
                    height: AppSpacing.x3l + AppSpacing.sm,
                    child: CachedNetworkImage(
                      imageUrl: it.listingImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${it.listingName} · ${AppStrings.quantity} ${it.quantity} · ${Formatters.dzdWhole(it.price * it.quantity)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        Divider(height: AppSpacing.x2l),
        if (addr != null) ...[
          Text(
            '📍 ${addr.street}, ${addr.city}, ${addr.wilaya}',
            style: AppTypography.bodySmall.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (pay != null)
          Text(
            '💳 ${_payLabel(pay)}',
            style: AppTypography.bodySmall,
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.checkoutEstimatedDelivery,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const CartSummaryCard(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.checkoutTermsBefore,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(AppStrings.menuTerms),
            ),
            Text(
              AppStrings.checkoutTermsAnd,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(AppStrings.checkoutReturnPolicy),
            ),
          ],
        ),
      ],
    );
  }
}
