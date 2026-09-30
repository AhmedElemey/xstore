import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../widgets/commission_payment_method_avatar.dart';

/// Step 1 of paying platform fees: pick how the money will be sent.
class CommissionPaymentMethodScreen extends StatelessWidget {
  const CommissionPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Text(context.l10n.commissionPaymentMethodTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            context.l10n.commissionPaymentMethodSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          const Gap(AppSpacing.lg),
          for (final method in CommissionPaymentMethod.values)
            _MethodTile(method: method),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method});

  final CommissionPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          onTap: () => context.push(
            AppRoutes.commissionPaymentReceiptPath(method.wireName),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                CommissionPaymentMethodAvatar(method: method),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commissionPaymentMethodLabel(context, method),
                        style: AppTypography.titleSmall.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        method == CommissionPaymentMethod.instaPay
                            ? context.l10n.commissionPaymentMethodBankHint
                            : context.l10n.commissionPaymentMethodWalletHint,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  context.chevronForward,
                  color: context.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
