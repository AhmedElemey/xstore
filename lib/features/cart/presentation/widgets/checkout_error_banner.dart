import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

String checkoutErrorMessage(String? k) => switch (k) {
      'noAddress' => AppStrings.checkoutErrorNoAddress,
      'noPayment' => AppStrings.checkoutErrorNoPayment,
      'noItems' => AppStrings.checkoutErrorNoItems,
      'invalidCard' => AppStrings.checkoutErrorCard,
      'noConsumer' => AppStrings.signInPrompt,
      _ => AppStrings.checkoutErrorGeneric,
    };

class CheckoutErrorBanner extends StatelessWidget {
  const CheckoutErrorBanner({super.key, required this.messageKey});

  final String? messageKey;

  @override
  Widget build(BuildContext context) {
    if (messageKey == null) return const SizedBox.shrink();
    return Material(
      color: AppColors.error.withValues(alpha: 0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        title: Text(
          checkoutErrorMessage(messageKey),
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
