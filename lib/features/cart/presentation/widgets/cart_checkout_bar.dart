import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
        ? AppStrings.cartProceedCheckout
        : AppStrings.cartProceedCheckoutTotal(
            Formatters.dzdWhole(checkout.total),
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.profileHeaderGradientEnd,
                    ],
                  ),
            color: disabled ? context.textDisabled : null,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: disabled
                  ? null
                  : () => context.push(AppRoutes.checkout),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
