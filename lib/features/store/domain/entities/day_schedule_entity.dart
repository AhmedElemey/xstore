import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_schedule_entity.freezed.dart';

enum DayOfWeek {
  saturday,
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

const egyptWeekOrder = <DayOfWeek>[
  DayOfWeek.saturday,
  DayOfWeek.sunday,
  DayOfWeek.monday,
  DayOfWeek.tuesday,
  DayOfWeek.wednesday,
  DayOfWeek.thursday,
  DayOfWeek.friday,
];

@freezed
class DayScheduleEntity with _$DayScheduleEntity {
  const factory DayScheduleEntity({
    required DayOfWeek day,
    required bool isOpen,
    required TimeOfDay openTime,
    required TimeOfDay closeTime,
    required bool is24Hours,
    required bool isClosed,
  }) = _DayScheduleEntity;
}

