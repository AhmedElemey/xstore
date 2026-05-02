import 'entities/day_schedule_entity.dart';

/// Pure validation helpers for vendor weekly schedules (testable without UI).
abstract final class StoreHoursValidator {
  /// Same rule as [StoreHoursNotifier.saveStoreHours] preflight: for each non-24h open day,
  /// closing time must be strictly after opening time.
  static bool isScheduleTimeOrderValid(List<DayScheduleEntity> schedule) {
    for (final day in schedule) {
      if (!day.isOpen || day.is24Hours) continue;
      final open = day.openTime.hour * 60 + day.openTime.minute;
      final close = day.closeTime.hour * 60 + day.closeTime.minute;
      if (close <= open) return false;
    }
    return true;
  }

  /// True when the list contains exactly one row per [DayOfWeek].
  static bool hasFullWeekCoverage(List<DayScheduleEntity> schedule) {
    if (schedule.length != DayOfWeek.values.length) return false;
    final seen = schedule.map((e) => e.day).toSet();
    return seen.length == DayOfWeek.values.length;
  }

  /// True when two or more rows share the same [DayOfWeek].
  static bool hasDuplicateDays(List<DayScheduleEntity> schedule) {
    final seen = <DayOfWeek>{};
    for (final d in schedule) {
      if (seen.contains(d.day)) return true;
      seen.add(d.day);
    }
    return false;
  }
}
