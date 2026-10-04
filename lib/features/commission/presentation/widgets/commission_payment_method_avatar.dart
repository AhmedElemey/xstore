import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/commission_payment_method.dart';

String commissionPaymentMethodLabel(
  BuildContext context,
  CommissionPaymentMethod method,
) => switch (method) {
  CommissionPaymentMethod.instaPay =>
    context.l10n.commissionPaymentMethodInstaPay,
  CommissionPaymentMethod.vodafoneCash =>
    context.l10n.commissionPaymentMethodVodafoneCash,
  CommissionPaymentMethod.orangeCash =>
    context.l10n.commissionPaymentMethodOrangeCash,
  CommissionPaymentMethod.etisalatCash =>
    context.l10n.commissionPaymentMethodEtisalatCash,
};

/// Brand-tinted circle identifying a payment method.
class CommissionPaymentMethodAvatar extends StatelessWidget {
  const CommissionPaymentMethodAvatar({super.key, required this.method});

  final CommissionPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final color = switch (method) {
      CommissionPaymentMethod.instaPay => AppColors.paymentInstaPay,
      CommissionPaymentMethod.vodafoneCash => AppColors.paymentVodafoneCash,
      CommissionPaymentMethod.orangeCash => AppColors.paymentOrangeCash,
      CommissionPaymentMethod.etisalatCash => AppColors.paymentEtisalatCash,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        method == CommissionPaymentMethod.instaPay
            ? LucideIcons.landmark
            : LucideIcons.smartphone,
        color: color,
        size: 22,
      ),
    );
  }
}
