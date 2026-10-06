import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.errorText,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.stockQuantityRequired.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
        ),
        const Gap(AppSpacing.sm),
        Row(
          children: [
            _StepperIcon(
              icon: LucideIcons.minus,
              onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
            ),
            const Gap(AppSpacing.md),
            SizedBox(
              width: 56,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppTypography.mono.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            _StepperIcon(
              icon: LucideIcons.plus,
              onTap: () => onChanged(quantity + 1),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: AppSpacing.md,
              start: AppSpacing.xs,
            ),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _StepperIcon extends StatelessWidget {
  const _StepperIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: context.glassColor,
      shape: CircleBorder(side: BorderSide(color: context.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? context.textPrimary : context.textDisabled,
          ),
        ),
      ),
    );
  }
}
