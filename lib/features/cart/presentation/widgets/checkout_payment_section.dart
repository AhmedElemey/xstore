import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
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
  late final FocusNode _numFocus;
  late final FocusNode _expFocus;
  late final FocusNode _cvvFocus;
  var _cardBlurred = false;
  var _expBlurred = false;
  var _cvvBlurred = false;

  @override
  void initState() {
    super.initState();
    _num = TextEditingController();
    _exp = TextEditingController();
    _cvv = TextEditingController();
    _note = TextEditingController();
    _numFocus = FocusNode()..addListener(_onNumFocus);
    _expFocus = FocusNode()..addListener(_onExpFocus);
    _cvvFocus = FocusNode()..addListener(_onCvvFocus);
  }

  void _onNumFocus() {
    if (!_numFocus.hasFocus) setState(() => _cardBlurred = true);
  }

  void _onExpFocus() {
    if (!_expFocus.hasFocus) setState(() => _expBlurred = true);
  }

  void _onCvvFocus() {
    if (!_cvvFocus.hasFocus) setState(() => _cvvBlurred = true);
  }

  @override
  void dispose() {
    _numFocus.dispose();
    _expFocus.dispose();
    _cvvFocus.dispose();
    _num.dispose();
    _exp.dispose();
    _cvv.dispose();
    _note.dispose();
    super.dispose();
  }

  static String _title(BuildContext context, PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => context.l10n.checkoutPayCodTitle,
        PaymentMethod.cibCard => context.l10n.checkoutPayCibTitle,
        PaymentMethod.dahabiCard => context.l10n.checkoutPayDahabiTitle,
        PaymentMethod.baridimob => context.l10n.checkoutPayBaridiTitle,
      };

  static String _sub(BuildContext context, PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => context.l10n.checkoutPayCodSubtitle,
        PaymentMethod.cibCard => context.l10n.checkoutPayCibSubtitle,
        PaymentMethod.dahabiCard => context.l10n.checkoutPayDahabiSubtitle,
        PaymentMethod.baridimob => context.l10n.checkoutPayBaridiSubtitle,
      };

  void _pushCard() {
    ref.read(checkoutProvider.notifier).updateCard(
          _num.text,
          _exp.text,
          _cvv.text,
        );
    setState(() {});
  }

  bool _showFieldError(bool blurred, String value) =>
      blurred || value.trim().isNotEmpty;

  String? _cardNumberError(AppLocalizations l10n) {
    if (!_showFieldError(_cardBlurred, _num.text)) return null;
    final n = _num.text.replaceAll(RegExp(r'\D'), '');
    if (n.isEmpty) return l10n.checkoutErrorCard;
    if (n.length < 12 || n.length > 19) return l10n.checkoutErrorCard;
    return null;
  }

  String? _expiryError(AppLocalizations l10n) {
    if (!_showFieldError(_expBlurred, _exp.text)) return null;
    final t = _exp.text.trim();
    if (t.isEmpty) return l10n.checkoutErrorExpiry;
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(t);
    if (m == null) return l10n.checkoutErrorExpiry;
    final month = int.tryParse(m.group(1)!);
    final yy = int.tryParse(m.group(2)!);
    if (month == null || yy == null || month < 1 || month > 12) {
      return l10n.checkoutErrorExpiry;
    }
    final year = 2000 + yy;
    final now = DateTime.now();
    final lastDay = DateTime(year, month + 1, 0);
    if (lastDay.isBefore(DateTime(now.year, now.month, 1))) {
      return l10n.checkoutErrorExpiry;
    }
    return null;
  }

  String? _cvvError(AppLocalizations l10n) {
    if (!_showFieldError(_cvvBlurred, _cvv.text)) return null;
    final d = _cvv.text.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return l10n.checkoutErrorCvv;
    if (d.length < 3 || d.length > 4) return l10n.checkoutErrorCvv;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    final l10n = context.l10n;
    const methods = PaymentMethod.values;

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
                              _title(context, m),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _sub(context, m),
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
          Row(
            children: [
              Icon(
                LucideIcons.lock,
                size: AppSpacing.lg,
                color: context.textSecondary,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.checkoutPaymentSecure,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Focus(
            focusNode: _numFocus,
            child: AuthTextField(
              label: l10n.checkoutCardNumber,
              controller: _num,
              keyboardType: TextInputType.number,
              prefixIcon: _cardBrandIcon(_num.text),
              errorText: _cardNumberError(l10n),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
              onChanged: (_) => _pushCard(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Focus(
                  focusNode: _expFocus,
                  child: AuthTextField(
                    label: l10n.checkoutCardExpiry,
                    controller: _exp,
                    keyboardType: TextInputType.number,
                    errorText: _expiryError(l10n),
                    inputFormatters: const [_ExpiryInputFormatter()],
                    onChanged: (_) => _pushCard(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Focus(
                  focusNode: _cvvFocus,
                  child: AuthTextField(
                    label: l10n.checkoutCardCvv,
                    controller: _cvv,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    errorText: _cvvError(l10n),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (_) => _pushCard(),
                  ),
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
            labelText: l10n.checkoutDeliveryNoteLabel,
            hintText: l10n.checkoutDeliveryNoteLabel,
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

class _ExpiryInputFormatter extends TextInputFormatter {
  const _ExpiryInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
