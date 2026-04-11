import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CheckoutProgress extends StatelessWidget {
  const CheckoutProgress({
    super.key,
    required this.step,
  });

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepColumn(context, 1, context.l10n.checkoutStepAddress),
          Expanded(child: _line(context, step > 1)),
          Icon(context.arrowForwardIcon, size: 16, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          _stepColumn(context, 2, context.l10n.checkoutStepPayment),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: _line(context, step > 2)),
          Icon(context.arrowForwardIcon, size: 16, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          _stepColumn(context, 3, context.l10n.checkoutStepConfirm),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, bool done) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        height: 2,
        color: done
            ? AppColors.success
            : context.textDisabled.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _stepColumn(BuildContext context, int n, String label) {
    final done = step > n;
    final active = step == n;
    return Column(
      children: [
        Container(
          width: AppSpacing.x2l + AppSpacing.sm,
          height: AppSpacing.x2l + AppSpacing.sm,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.success
                : (active ? AppColors.primary : context.backgroundColor),
            border: Border.all(
              color: active || done
                  ? AppColors.transparent
                  : context.textDisabled,
              width: 2,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: AppColors.white, size: 18)
                : Text(
                    '$n',
                    style: AppTypography.labelLarge.copyWith(
                      color: active ? AppColors.white : context.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: AppSpacing.x4l,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: active ? AppColors.primary : context.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
