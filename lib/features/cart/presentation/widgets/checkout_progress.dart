import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit stepper: three step labels joined by lines. Reached steps (and their
/// lines) take the brand accent; the current step sits in a glowing pill.
class CheckoutProgress extends StatelessWidget {
  const CheckoutProgress({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final accent = context.brandGradient.first;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _label(context, 1, context.l10n.checkoutStepAddress, accent),
          Expanded(child: _line(context, step > 1, accent)),
          _label(context, 2, context.l10n.checkoutStepPayment, accent),
          Expanded(child: _line(context, step > 2, accent)),
          _label(context, 3, context.l10n.checkoutStepConfirm, accent),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, bool done, Color accent) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: done ? accent : context.borderColor,
    );
  }

  Widget _label(BuildContext context, int n, String text, Color accent) {
    final reached = step >= n;
    final current = step == n;
    return Container(
      padding: current
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs)
          : null,
      decoration: current
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 12),
              ],
            )
          : null,
      child: Text(
        text,
        maxLines: 1,
        style: AppTypography.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: current
              ? context.textPrimary
              : (reached ? context.linkColor : context.textSecondary),
        ),
      ),
    );
  }
}
