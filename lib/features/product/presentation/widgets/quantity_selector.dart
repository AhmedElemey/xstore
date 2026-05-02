import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/animations/animated_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final int maxQuantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowStock = maxQuantity <= 5 && maxQuantity > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.quantity,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _StepperIcon(
                    icon: LucideIcons.minus,
                    onTap: quantity > 1 ? onDecrement : null,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: AppSpacing.x3l + AppSpacing.sm,
                    child: AnimatedCounter(
                      value: quantity,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StepperIcon(
                    icon: LucideIcons.plus,
                    onTap: quantity < maxQuantity ? onIncrement : null,
                  ),
                ],
              ),
            ],
          ),
          if (lowStock) ...[
            const Gap(AppSpacing.sm),
            Text(
              '${context.l10n.onlyLeftPrefix}$maxQuantity${context.l10n.onlyLeftSuffix}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  const _StepperIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: disabled
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.primaryContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: AppSpacing.xl + AppSpacing.xs,
            color: disabled
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
