import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QtyButton(
              enabled: enabled,
              icon: atMin ? LucideIcons.trash2 : LucideIcons.minus,
              color: atMin ? AppColors.error : AppColors.textPrimary,
              onTap: onDecrement,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                child: InkWell(
                  onTap: enabled ? onEditQuantity : null,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      '$quantity',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _QtyButton(
              enabled: enabled && !atMax,
              icon: LucideIcons.plus,
              color: AppColors.primary,
              onTap: onIncrement,
            ),
          ],
        ),
        if (lowStock) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppStrings.onlyLeftPrefix}$maxQuantity${AppStrings.onlyLeftSuffix}',
            style: AppTypography.labelSmall.copyWith(color: AppColors.warning),
          ),
        ],
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.enabled,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final bool enabled;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        side: BorderSide(
          color: enabled ? AppColors.textDisabled : AppColors.textDisabled.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: AppSpacing.md + AppSpacing.xs,
            color: enabled ? color : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
