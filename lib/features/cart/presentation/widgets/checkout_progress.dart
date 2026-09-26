import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit checkout trail: Address → Payment → Review on one line. Checkout
/// is a single page, so the trail shows readiness: Address lights up once
/// one is chosen, Payment is always cash on delivery, Review is where the
/// shopper places the order.
class CheckoutProgress extends StatelessWidget {
  const CheckoutProgress({super.key, required this.hasAddress});

  final bool hasAddress;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    final idle = context.textSecondary;
    Widget label(String text, bool lit) => Text(
          text,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: lit ? accent : idle,
          ),
        );
    Widget trail(bool lit) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: lit
                    ? [accent, accent]
                    : [accent, accent.withValues(alpha: 0.15)],
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          label(context.l10n.checkoutStepAddress, hasAddress),
          trail(hasAddress),
          label(context.l10n.checkoutStepPayment, hasAddress),
          trail(false),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md - 2,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 14),
              ],
            ),
            child: Text(
              context.l10n.checkoutStepConfirm,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Numbered section title ("1  Deliver to") used by the checkout sections.
class CheckoutSectionTitle extends StatelessWidget {
  const CheckoutSectionTitle({
    super.key,
    required this.number,
    required this.title,
  });

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 14),
            ],
          ),
          child: Text(
            '$number',
            style: AppTypography.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
