import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/store/domain/entities/day_schedule_entity.dart';
import 'package:xstore/features/store/domain/store_hours_validator.dart';

DayScheduleEntity _closed(DayOfWeek d) => DayScheduleEntity(
      day: d,
      isOpen: false,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 18, minute: 0),
      is24Hours: false,
      isClosed: true,
    );

DayScheduleEntity _openHours(
  DayOfWeek d, {
  required TimeOfDay openTime,
  required TimeOfDay closeTime,
}) =>
    DayScheduleEntity(
      day: d,
      isOpen: true,
      openTime: openTime,
      closeTime: closeTime,
      is24Hours: false,
      isClosed: false,
    );

List<DayScheduleEntity> _fullWeekBaseline() =>
    DayOfWeek.values.map(_closed).toList();

void main() {
  test('closing before opening marks invalid times', () {
    final schedule = _fullWeekBaseline()
      ..[0] = _openHours(
        DayOfWeek.saturday,
        openTime: const TimeOfDay(hour: 10, minute: 0),
        closeTime: const TimeOfDay(hour: 10, minute: 0),
      );

    expect(StoreHoursValidator.isScheduleTimeOrderValid(schedule), isFalse);
  });

  test('closing after opening is valid', () {
    final schedule = _fullWeekBaseline()
      ..[0] = _openHours(
        DayOfWeek.saturday,
        openTime: const TimeOfDay(hour: 9, minute: 0),
        closeTime: const TimeOfDay(hour: 18, minute: 0),
      );

    expect(StoreHoursValidator.isScheduleTimeOrderValid(schedule), isTrue);
  });

  test('duplicate days detector', () {
    final base = [..._fullWeekBaseline()];
    final s = [...base, _closed(DayOfWeek.saturday)];
    expect(StoreHoursValidator.hasDuplicateDays(s), isTrue);
    expect(StoreHoursValidator.hasFullWeekCoverage(s), isFalse);
  });

  test('seven unique days satisfies coverage helper', () {
    expect(
      StoreHoursValidator.hasFullWeekCoverage(_fullWeekBaseline()),
      isTrue,
    );
  });
}
