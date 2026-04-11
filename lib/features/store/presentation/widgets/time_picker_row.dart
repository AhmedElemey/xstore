import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class TimePickerRow extends StatelessWidget {
  const TimePickerRow({
    super.key,
    required this.fromLabel,
    required this.toLabel,
    required this.from,
    required this.to,
    required this.onTapFrom,
    required this.onTapTo,
  });

  final String fromLabel;
  final String toLabel;
  final String from;
  final String to;
  final VoidCallback onTapFrom;
  final VoidCallback onTapTo;

  @override
  Widget build(BuildContext context) {
    final fromWidget = _TimePill(label: fromLabel, value: from, onTap: onTapFrom);
    final toWidget = _TimePill(label: toLabel, value: to, onTap: onTapTo);
    final arrow = Icon(context.chevronForward, size: 18, color: context.textSecondary);
    return Row(
      children: context.isArabic
          ? [Expanded(child: toWidget), const SizedBox(width: AppSpacing.sm), arrow, const SizedBox(width: AppSpacing.sm), Expanded(child: fromWidget)]
          : [Expanded(child: fromWidget), const SizedBox(width: AppSpacing.sm), arrow, const SizedBox(width: AppSpacing.sm), Expanded(child: toWidget)],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: context.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side:  BorderSide(color: context.isDark ? AppColors.white :AppColors.primary),
          ),
          child: Text(value,style: AppTypography.bodySmall.copyWith(color: context.textPrimary),),
        ),
      ],
    );
  }
}

