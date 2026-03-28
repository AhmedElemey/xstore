import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/cart_provider.dart';

Future<void> showCartClearConfirmSheet(BuildContext context, WidgetRef ref) async {
  final cart = ref.read(cartProvider);
  final n = cart.items.length;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.cartClearTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.cartClearBody(n),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(cartProvider.notifier).clearCart();
                  },
                  child: Text(AppStrings.cartClearConfirm),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.paddingOf(ctx).bottom + AppSpacing.sm),
        ],
      ),
    ),
  );
}
