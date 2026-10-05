import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/animations/animated_widgets.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
    final lowStock = maxQuantity <= 5 && maxQuantity > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.quantity,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.labelColor,
                ),
              ),
              const Spacer(),
              // Bordered pill: [-] n [+]
              Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperButton(
                      icon: LucideIcons.minus,
                      onTap: quantity > 1 ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 28,
                      child: Center(
                        child: AnimatedCounter(
                          value: quantity,
                          style: AppTypography.mono.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    _StepperButton(
                      icon: LucideIcons.plus,
                      onTap: quantity < maxQuantity ? onIncrement : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lowStock) ...[
            const Gap(AppSpacing.sm),
            Text(
              '${context.l10n.onlyLeftPrefix}$maxQuantity${context.l10n.onlyLeftSuffix}',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.amberColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: disabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 18,
            color: disabled
                ? context.labelColor.withValues(alpha: 0.5)
                : context.textPrimary,
          ),
        ),
      ),
    );
  }
}
