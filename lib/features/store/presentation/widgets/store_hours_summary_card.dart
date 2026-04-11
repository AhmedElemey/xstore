import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/day_schedule_entity.dart';
import '../../domain/entities/store_hours_entity.dart';

class StoreHoursSummaryCard extends StatelessWidget {
  const StoreHoursSummaryCard({
    super.key,
    required this.schedule,
  });

  final List<DayScheduleEntity> schedule;

  @override
  Widget build(BuildContext context) {
    final today = _dayFromDateTime(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: schedule.map((day) {
          final isToday = day.day == today;
          final isOpen = day.isOpen;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              border: Border(
                left: isToday ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dayShortLabel(context, day.day),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  isOpen
                      ? '${day.openTime.formatForStore(context)} - ${day.closeTime.formatForStore(context)}'
                      : context.l10n.closedLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: isOpen ? context.textSecondary : AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _dayShortLabel(BuildContext context, DayOfWeek day) {
  return switch (day) {
    DayOfWeek.saturday => context.l10n.dayShortSat,
    DayOfWeek.sunday => context.l10n.dayShortSun,
    DayOfWeek.monday => context.l10n.dayShortMon,
    DayOfWeek.tuesday => context.l10n.dayShortTue,
    DayOfWeek.wednesday => context.l10n.dayShortWed,
    DayOfWeek.thursday => context.l10n.dayShortThu,
    DayOfWeek.friday => context.l10n.dayShortFri,
  };
}

DayOfWeek _dayFromDateTime(DateTime date) {
  return switch (date.weekday) {
    DateTime.saturday => DayOfWeek.saturday,
    DateTime.sunday => DayOfWeek.sunday,
    DateTime.monday => DayOfWeek.monday,
    DateTime.tuesday => DayOfWeek.tuesday,
    DateTime.wednesday => DayOfWeek.wednesday,
    DateTime.thursday => DayOfWeek.thursday,
    _ => DayOfWeek.friday,
  };
}

