import 'package:flutter/material.dart';

import '../../features/store/domain/entities/day_schedule_entity.dart';
import '../../features/store/domain/entities/store_hours_entity.dart';

final mockStoreHours = StoreHoursEntity(
  vendorId: 'vendor_001',
  isStoreOpen: true,
  temporaryMessage: null,
  updatedAt: DateTime.now(),
  schedule: const [
    DayScheduleEntity(
      day: DayOfWeek.saturday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.sunday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.monday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.tuesday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.wednesday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.thursday,
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
      is24Hours: false,
      isClosed: false,
    ),
    DayScheduleEntity(
      day: DayOfWeek.friday,
      isOpen: false,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 14, minute: 0),
      is24Hours: false,
      isClosed: true,
    ),
  ],
);

