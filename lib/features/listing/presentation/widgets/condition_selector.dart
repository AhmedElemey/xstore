import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.listingConditionFieldLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((o) {
            final isSel = o == selected;
            final display = optionLabel?.call(o) ?? o;
            return ChoiceChip(
              label: Text(
                display,
                style: TextStyle(
                  color: isSel ? AppColors.white : AppColors.materialGrey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSel,
              onSelected: (_) => onChanged(o),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.transparent,
              side: BorderSide(
                color: hasError && !isSel ? AppColors.error : context.textDisabled,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
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
