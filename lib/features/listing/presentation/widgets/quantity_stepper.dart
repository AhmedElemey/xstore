import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
          context.l10n.stockQuantityRequired,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Gap(AppSpacing.md),
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
                style: Theme.of(context).textTheme.titleMedium,
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
            padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.xs),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
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
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.1)
          : context.textDisabled.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: SizedBox(
          width: AppSpacing.x3l + AppSpacing.md,
          height: AppSpacing.x3l + AppSpacing.md,
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : context.textDisabled,
          ),
        ),
      ),
    );
  }
}
