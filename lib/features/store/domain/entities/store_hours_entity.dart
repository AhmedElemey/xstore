import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'day_schedule_entity.dart';

part 'store_hours_entity.freezed.dart';

@freezed
class StoreHoursEntity with _$StoreHoursEntity {
  const factory StoreHoursEntity({
    required String vendorId,
    required bool isStoreOpen,
    required String? temporaryMessage,
    required List<DayScheduleEntity> schedule,
    required DateTime updatedAt,
  }) = _StoreHoursEntity;
}

@freezed
class StoreStatusEntity with _$StoreStatusEntity {
  const factory StoreStatusEntity({
    required bool isOpen,
    required DayScheduleEntity? currentDayHours,
    required DayScheduleEntity? nextOpenDay,
    required String statusLabel,
    required String? nextOpenLabel,
  }) = _StoreStatusEntity;
}

extension TimeOfDayFormat on TimeOfDay {
  String formatForStore(BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return MaterialLocalizations.of(context).formatTimeOfDay(
      this,
      alwaysUse24HourFormat: false,
    );
  }
}

