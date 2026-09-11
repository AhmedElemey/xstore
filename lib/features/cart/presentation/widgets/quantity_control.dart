import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.enabled,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEditQuantity,
  });

  final int quantity;
  final int maxQuantity;
  final bool enabled;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEditQuantity;

  @override
  Widget build(BuildContext context) {
    final atMin = quantity <= 1;
    final atMax = quantity >= maxQuantity;
    final lowStock = maxQuantity <= 3 && enabled;
    final border = enabled ? AppColors.primary : context.textDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppSpacing.x3l),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtySegment(
                enabled: enabled,
                onTap: onDecrement,
                child: Icon(
                  atMin ? LucideIcons.trash2 : LucideIcons.minus,
                  size: AppSpacing.md + AppSpacing.xs,
                  color: enabled
                      ? (atMin ? AppColors.error : context.textPrimary)
                      : context.textDisabled,
                ),
              ),
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: enabled ? onEditQuantity : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      '$quantity',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? context.textPrimary
                            : context.textDisabled,
                      ),
                    ),
                  ),
                ),
              ),
              _QtySegment(
                enabled: enabled && !atMax,
                onTap: onIncrement,
                child: Icon(
                  LucideIcons.plus,
                  size: AppSpacing.md + AppSpacing.xs,
                  color: enabled && !atMax
                      ? context.textPrimary
                      : context.textDisabled,
                ),
              ),
            ],
          ),
        ),
        if (lowStock) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${context.l10n.onlyLeftPrefix}$maxQuantity${context.l10n.onlyLeftSuffix}',
            style: AppTypography.labelSmall.copyWith(color: AppColors.warning),
          ),
        ],
      ],
    );
  }
}

class _QtySegment extends StatelessWidget {
  const _QtySegment({
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: child,
        ),
      ),
    );
  }
}
