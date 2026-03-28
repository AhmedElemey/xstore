import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

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
          _stepColumn(1, AppStrings.checkoutStepAddress),
          Expanded(child: _line(step > 1)),
          _stepColumn(2, AppStrings.checkoutStepPayment),
          Expanded(child: _line(step > 2)),
          _stepColumn(3, AppStrings.checkoutStepConfirm),
        ],
      ),
    );
  }

  Widget _line(bool done) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        height: 2,
        color: done
            ? AppColors.success
            : AppColors.textDisabled.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _stepColumn(int n, String label) {
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
                : (active ? AppColors.primary : AppColors.background),
            border: Border.all(
              color: active || done
                  ? AppColors.transparent
                  : AppColors.textDisabled,
              width: 2,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: AppColors.white, size: 18)
                : Text(
                    '$n',
                    style: AppTypography.labelLarge.copyWith(
                      color: active ? AppColors.white : AppColors.textSecondary,
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
              color: active ? AppColors.primary : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
