import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
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
    final label = checkout.selectedCount == 0
        ? context.l10n.cartProceedCheckout
        : context.l10n.cartProceedCheckoutTotal(
            context.formatCurrency(checkout.total),
          );

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.08),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, -AppSpacing.xs),
          ),
        ],
      ),
      child: XstoreButton(
        label: label,
        onPressed: disabled ? null : () => context.push(AppRoutes.checkout),
      ),
    );
  }
}
