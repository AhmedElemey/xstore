import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _StepperIcon(
                    icon: Icons.remove_rounded,
                    onTap: quantity > 1 ? onDecrement : null,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 40,
                    child: Text(
                      '$quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StepperIcon(
                    icon: Icons.add_rounded,
                    onTap: quantity < maxQuantity ? onIncrement : null,
                  ),
                ],
              ),
            ],
          ),
          if (lowStock) ...[
            const Gap(AppSpacing.xs),
            Text(
              'Only $maxQuantity left!',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFFD97706),
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            icon,
            size: 22,
            color: disabled
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
