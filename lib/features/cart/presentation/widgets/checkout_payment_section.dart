import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
    _note = TextEditingController(
      text: ref.read(checkoutProvider).deliveryNote,
    );
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

    final amber = context.amberColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.checkoutPaymentTitle,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Cash on delivery is the hero payment: an amber card.
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                amber.withValues(alpha: 0.16),
                amber.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: amber, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    colors: [
                      Color.lerp(amber, AppColors.white, 0.7)!,
                      amber,
                      Color.lerp(amber, AppColors.black, 0.55)!,
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: amber.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    LucideIcons.banknote,
                    size: 22,
                    color: AppColors.darkBackground,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkoutPayCodTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.checkoutPayCodSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _note,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: l10n.checkoutDeliveryNoteLabel,
            hintText: l10n.checkoutDeliveryNoteLabel,
          ),
          onChanged: notifier.updateDeliveryNote,
        ),
      ],
    );
  }
}
