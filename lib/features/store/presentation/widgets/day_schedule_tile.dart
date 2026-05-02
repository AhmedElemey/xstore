import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/day_schedule_entity.dart';
import '../../domain/entities/store_hours_entity.dart';
import 'time_picker_row.dart';

class DayScheduleTile extends StatelessWidget {
  const DayScheduleTile({
    super.key,
    required this.schedule,
    required this.onToggleDay,
    required this.onToggle24Hours,
    required this.onPickOpenTime,
    required this.onPickCloseTime,
  });

  final DayScheduleEntity schedule;
  final VoidCallback onToggleDay;
  final VoidCallback onToggle24Hours;
  final ValueChanged<TimeOfDay> onPickOpenTime;
  final ValueChanged<TimeOfDay> onPickCloseTime;

  @override
  Widget build(BuildContext context) {
    final isOpen = schedule.isOpen;
    final bg = isOpen
        ? (context.isDark ?  AppColors.primary.withValues(alpha: 0.12) : AppColors.indigoTint50)
        : context.surfaceColor;
    final border = isOpen ? AppColors.primary : context.borderColor;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: isOpen ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch.adaptive(value: isOpen, onChanged: (_) => onToggleDay()),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _dayLabel(context, schedule.day),
                    style: AppTypography.bodyLarge.copyWith(
                      color: isOpen ? context.textPrimary : context.textSecondary,
                      fontWeight: isOpen ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  isOpen ? context.l10n.openLabel : context.l10n.closedLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: AppSpacing.sm),
              if (!schedule.is24Hours)
                TimePickerRow(
                  fromLabel: context.l10n.from,
                  toLabel: context.l10n.to,
                  from: schedule.openTime.formatForStore(context),
                  to: schedule.closeTime.formatForStore(context),
                  onTapFrom: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: schedule.openTime,
                    );
                    if (picked != null) onPickOpenTime(picked);
                  },
                  onTapTo: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: schedule.closeTime,
                    );
                    if (picked != null) onPickCloseTime(picked);
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    context.l10n.open24Hours,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.success),
                  ),
                ),
              Row(
                children: [
                  Checkbox.adaptive(value: schedule.is24Hours, onChanged: (_) => onToggle24Hours()),
                  Text(context.l10n.open24Hours, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _dayLabel(BuildContext context, DayOfWeek day) {
  return switch (day) {
    DayOfWeek.saturday => context.l10n.daySaturday,
    DayOfWeek.sunday => context.l10n.daySunday,
    DayOfWeek.monday => context.l10n.dayMonday,
    DayOfWeek.tuesday => context.l10n.dayTuesday,
    DayOfWeek.wednesday => context.l10n.dayWednesday,
    DayOfWeek.thursday => context.l10n.dayThursday,
    DayOfWeek.friday => context.l10n.dayFriday,
  };
}

