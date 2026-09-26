import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

class CartCheckoutBar extends ConsumerWidget {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(
      cartProvider.select(
        (c) => (
          hasItems: c.items.isNotEmpty,
          selectedCount: c.selectedAvailableItems.length,
          allSelectedUnavailable: c.selectedAvailableItems.every(
            (e) => !e.isAvailable,
          ),
          isUpdating: c.isUpdating,
          total: c.total,
        ),
      ),
    );
    final canCheckout = checkout.hasItems &&
        checkout.selectedCount > 0 &&
        !checkout.allSelectedUnavailable;
    final disabled = !canCheckout || checkout.isUpdating;
    // Orbit bar: amount due in cash on the left, Checkout on the right.
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cartPayInCash,
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                context.formatCurrency(checkout.total),
                style: AppTypography.titleSmall.copyWith(
                  color: context.cashColor,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: XstoreButton(
              label: context.l10n.checkoutTitle,
              onPressed: disabled ? null : () => context.push(AppRoutes.checkout),
            ),
          ),
        ],
      ),
    );
  }
}
