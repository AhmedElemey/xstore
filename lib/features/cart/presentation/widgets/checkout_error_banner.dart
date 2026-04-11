import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

String checkoutErrorMessage(BuildContext context, String? k) => switch (k) {
      'noAddress' => context.l10n.checkoutErrorNoAddress,
      'noPayment' => context.l10n.checkoutErrorNoPayment,
      'noItems' => context.l10n.checkoutErrorNoItems,
      'invalidCard' => context.l10n.checkoutErrorCard,
      'noConsumer' => context.l10n.signInPrompt,
      _ => context.l10n.checkoutErrorGeneric,
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
          checkoutErrorMessage(context, messageKey),
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
