import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

class PriceRangeSlider extends StatelessWidget {
  const PriceRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    required this.minController,
    required this.maxController,
  });

  final double min;
  final double max;
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.priceRange, style: AppTypography.titleMedium),
        const Gap(AppSpacing.md),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: 20,
          activeColor: AppColors.primary,
          labels: RangeLabels(
            values.start.round().toString(),
            values.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.minPriceLabel,
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.maxPriceLabel,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
