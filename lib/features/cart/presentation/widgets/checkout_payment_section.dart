import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Launch checkout is Cash on Delivery only — no card fields are collected.
class CheckoutPaymentSection extends ConsumerStatefulWidget {
  const CheckoutPaymentSection({super.key});

  @override
  ConsumerState<CheckoutPaymentSection> createState() =>
      _CheckoutPaymentSectionState();
}

class _CheckoutPaymentSectionState
    extends ConsumerState<CheckoutPaymentSection> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(checkoutProvider.notifier);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.checkoutPaymentTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.banknote, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkoutPayCodTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.checkoutPayCodSubtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _note,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: l10n.checkoutDeliveryNoteLabel,
            hintText: l10n.checkoutDeliveryNoteLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: notifier.updateDeliveryNote,
        ),
      ],
    );
  }
}

/// Review-step label. Historical non-COD values still parse from old orders.
String checkoutPaymentLabel(BuildContext context, PaymentMethod m) =>
    switch (m) {
      PaymentMethod.cashOnDelivery =>
        context.l10n.ordersPaymentCashOnDelivery,
      PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
      PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
      PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
    };
