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

class CartCheckoutBar extends ConsumerWidget {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final selected = cart.selectedAvailableItems.toList();
    final canCheckout = cart.items.isNotEmpty &&
        selected.isNotEmpty &&
        !selected.every((e) => !e.isAvailable);

    final disabled = !canCheckout || cart.isUpdating;

    final label = selected.isEmpty
        ? AppStrings.cartProceedCheckout
        : AppStrings.cartProceedCheckoutTotal(Formatters.dzdWhole(cart.total));

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
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
            color: disabled ? AppColors.textDisabled : null,
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
