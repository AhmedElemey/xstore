import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Chip row for product condition (segmented-style).
class ConditionSelector extends StatelessWidget {
  const ConditionSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.errorText,
    this.optionLabel,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final String? errorText;

  /// Maps stored option value (e.g. English key) to display text.
  final String Function(String option)? optionLabel;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final selectedBg = context.isDark ? context.textPrimary : AppColors.primary;
    final selectedFg = context.isDark ? AppColors.darkOnBrand : AppColors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.listingConditionFieldLabel.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
        ),
        const Gap(AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((o) {
            final isSel = o == selected;
            final display = optionLabel?.call(o) ?? o;
            return ChoiceChip(
              label: Text(
                display,
                style: AppTypography.labelLarge.copyWith(
                  color: isSel ? selectedFg : context.textSecondary,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
              selected: isSel,
              onSelected: (_) => onChanged(o),
              selectedColor: selectedBg,
              backgroundColor: context.glassColor,
              shape: const StadiumBorder(),
              side: BorderSide(
                color: isSel
                    ? selectedBg
                    : (hasError ? AppColors.error : context.borderColor),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
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
