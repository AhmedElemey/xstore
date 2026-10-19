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
    final canCheckout =
        checkout.hasItems &&
        checkout.selectedCount > 0 &&
        !checkout.allSelectedUnavailable;
    final disabled = !canCheckout || checkout.isUpdating;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.borderColor)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            // The amount the customer pays is amber, in mono digits.
            if (checkout.selectedCount > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.cartTotalLine,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.formatCurrency(checkout.total),
                    style: AppTypography.mono.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.amberColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: XstoreButton(
                label: context.l10n.cartProceedCheckout,
                onPressed: disabled
                    ? null
                    : () => context.push(AppRoutes.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
