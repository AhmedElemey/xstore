import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Chip row for product condition (segmented-style).
class ConditionSelector extends StatelessWidget {
  const ConditionSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((o) {
            final isSel = o == selected;
            return ChoiceChip(
              label: Text(
                o,
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSel,
              onSelected: (_) => onChanged(o),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: hasError && !isSel ? AppColors.error : AppColors.textDisabled,
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
