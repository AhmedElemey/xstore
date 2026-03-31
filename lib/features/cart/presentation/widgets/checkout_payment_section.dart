import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CheckoutPaymentSection extends ConsumerStatefulWidget {
  const CheckoutPaymentSection({super.key});

  @override
  ConsumerState<CheckoutPaymentSection> createState() =>
      _CheckoutPaymentSectionState();
}

class _CheckoutPaymentSectionState
    extends ConsumerState<CheckoutPaymentSection> {
  late final TextEditingController _num;
  late final TextEditingController _exp;
  late final TextEditingController _cvv;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _num = TextEditingController();
    _exp = TextEditingController();
    _cvv = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _num.dispose();
    _exp.dispose();
    _cvv.dispose();
    _note.dispose();
    super.dispose();
  }

  static String _title(PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => AppStrings.checkoutPayCodTitle,
        PaymentMethod.cibCard => AppStrings.checkoutPayCibTitle,
        PaymentMethod.dahabiCard => AppStrings.checkoutPayDahabiTitle,
        PaymentMethod.baridimob => AppStrings.checkoutPayBaridiTitle,
      };

  static String _sub(PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => AppStrings.checkoutPayCodSubtitle,
        PaymentMethod.cibCard => AppStrings.checkoutPayCibSubtitle,
        PaymentMethod.dahabiCard => AppStrings.checkoutPayDahabiSubtitle,
        PaymentMethod.baridimob => AppStrings.checkoutPayBaridiSubtitle,
      };

  void _pushCard() {
    ref.read(checkoutProvider.notifier).updateCard(
          _num.text,
          _exp.text,
          _cvv.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    const methods = PaymentMethod.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.checkoutPaymentTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final m in methods)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: InkWell(
                onTap: () => notifier.selectPayment(m),
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(
                      color: st.selectedPayment == m
                          ? AppColors.primary
                          : context.textDisabled,
                      width: st.selectedPayment == m ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<PaymentMethod>(
                        value: m,
                        groupValue: st.selectedPayment, // ignore: deprecated_member_use
                        onChanged: (_) => notifier.selectPayment(m), // ignore: deprecated_member_use
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title(m),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _sub(m),
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
              ),
            ),
          ),
        if (st.selectedPayment == PaymentMethod.cibCard) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _num,
            decoration: InputDecoration(
              labelText: AppStrings.checkoutCardNumber,
              border: const OutlineInputBorder(),
              prefixIcon: _cardBrandIcon(_num.text),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _pushCard(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _exp,
                  decoration: const InputDecoration(
                    labelText: AppStrings.checkoutCardExpiry,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _pushCard(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _cvv,
                  decoration: const InputDecoration(
                    labelText: AppStrings.checkoutCardCvv,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onChanged: (_) => _pushCard(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _note,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: AppStrings.checkoutDeliveryNoteLabel,
            hintText: AppStrings.checkoutDeliveryNoteHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: notifier.updateDeliveryNote,
        ),
      ],
    );
  }

  Widget? _cardBrandIcon(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return null;
    final first = d[0];
    if (first == '4') {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Text('VISA', style: TextStyle(fontWeight: FontWeight.w800)),
      );
    }
    if (first == '5') {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Text('MC', style: TextStyle(fontWeight: FontWeight.w800)),
      );
    }
    return null;
  }
}
