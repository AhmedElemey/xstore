import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/day_schedule_entity.dart';

Future<void> showCopyHoursSheet({
  required BuildContext context,
  required List<DayScheduleEntity> schedule,
  required void Function(DayOfWeek source, List<DayOfWeek> targets) onApply,
}) async {
  var source = DayOfWeek.saturday;
  final selected = <DayOfWeek>{
    DayOfWeek.sunday,
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
  };
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.copyHoursToAll, style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(context.l10n.copyFrom),
                    const SizedBox(width: AppSpacing.sm),
                    DropdownButton<DayOfWeek>(
                      value: source,
                      items: egyptWeekOrder
                          .map((d) => DropdownMenuItem(value: d, child: Text(_dayLabel(context, d))))
                          .toList(),
                      onChanged: (v) => setSheet(() => source = v ?? DayOfWeek.saturday),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setSheet(() {
                        selected
                          ..clear()
                          ..addAll(egyptWeekOrder.where((e) => e != source));
                      }),
                      child: Text(context.l10n.selectAllDays),
                    ),
                    TextButton(
                      onPressed: () => setSheet(selected.clear),
                      child: Text(context.l10n.deselectAllDays),
                    ),
                  ],
                ),
                ...egyptWeekOrder.where((e) => e != source).map(
                      (day) => CheckboxListTile(
                        value: selected.contains(day),
                        onChanged: (_) => setSheet(() {
                          if (selected.contains(day)) {
                            selected.remove(day);
                          } else {
                            selected.add(day);
                          }
                        }),
                        title: Text(_dayLabel(context, day)),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          onApply(source, selected.toList());
                          Navigator.pop(ctx);
                        },
                        child: Text(context.l10n.applyToSelectedDays),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
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

