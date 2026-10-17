import 'package:flutter/material.dart';

import '../../domain/entities/day_schedule_entity.dart';

class DayScheduleModel {
  const DayScheduleModel({
    required this.day,
    required this.isOpen,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.is24Hours,
    required this.isClosed,
  });

  final DayOfWeek day;
  final bool isOpen;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final bool is24Hours;
  final bool isClosed;

  factory DayScheduleModel.fromEntity(DayScheduleEntity e) => DayScheduleModel(
        day: e.day,
        isOpen: e.isOpen,
        openHour: e.openTime.hour,
        openMinute: e.openTime.minute,
        closeHour: e.closeTime.hour,
        closeMinute: e.closeTime.minute,
        is24Hours: e.is24Hours,
        isClosed: e.isClosed,
      );

  DayScheduleEntity toEntity() => DayScheduleEntity(
        day: day,
        isOpen: isOpen,
        openTime: TimeOfDay(hour: openHour, minute: openMinute),
        closeTime: TimeOfDay(hour: closeHour, minute: closeMinute),
        is24Hours: is24Hours,
        isClosed: isClosed,
      );
}

