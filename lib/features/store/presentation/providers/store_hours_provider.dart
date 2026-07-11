import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/store_hours_datasource.dart';
import '../../data/repositories/store_hours_repository_impl.dart';
import '../../domain/entities/day_schedule_entity.dart';
import '../../domain/entities/store_hours_entity.dart';
import '../../domain/repositories/store_hours_repository.dart';
import '../../domain/usecases/get_store_hours_usecase.dart';
import '../../domain/usecases/toggle_store_status_usecase.dart';
import '../../domain/store_hours_validator.dart';
import '../../domain/usecases/update_store_hours_usecase.dart';

part 'store_hours_provider.freezed.dart';
part 'store_hours_provider.g.dart';

enum StorePreset {
  standard,
  extended,
  morningOnly,
  fullWeek,
  weekdaysOnly,
  withoutFriday,
}

@freezed
class StoreHoursState with _$StoreHoursState {
  const factory StoreHoursState({
    required StoreHoursEntity? original,
    required StoreHoursEntity? current,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool isTogglingStatus,
    @Default(false) bool hasChanges,
    String? error,
  }) = _StoreHoursState;
}

extension StoreHoursStateX on StoreHoursState {
  bool get isStoreOpen => current?.isStoreOpen ?? false;

  DayScheduleEntity? get todaySchedule {
    final hours = current;
    if (hours == null) return null;
    final day = _dayFromDateTime(DateTime.now());
    return hours.schedule.where((e) => e.day == day).firstOrNull;
  }
}

@riverpod
StoreHoursDataSource storeHoursDataSource(StoreHoursDataSourceRef ref) {
  return StoreHoursDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
StoreHoursRepository storeHoursRepository(StoreHoursRepositoryRef ref) {
  return StoreHoursRepositoryImpl(ref.watch(storeHoursDataSourceProvider));
}

@riverpod
GetStoreHoursUseCase getStoreHoursUseCase(GetStoreHoursUseCaseRef ref) {
  return GetStoreHoursUseCase(ref.watch(storeHoursRepositoryProvider));
}

@riverpod
UpdateStoreHoursUseCase updateStoreHoursUseCase(UpdateStoreHoursUseCaseRef ref) {
  return UpdateStoreHoursUseCase(ref.watch(storeHoursRepositoryProvider));
}

@riverpod
ToggleStoreStatusUseCase toggleStoreStatusUseCase(ToggleStoreStatusUseCaseRef ref) {
  return ToggleStoreStatusUseCase(ref.watch(storeHoursRepositoryProvider));
}

@Riverpod(keepAlive: true)
class StoreHoursNotifier extends _$StoreHoursNotifier {
  @override
  StoreHoursState build() => const StoreHoursState(original: null, current: null);

  Future<void> fetchStoreHours() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null || user.role != UserRole.vendor) return;
    final vendorId = user.id;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getStoreHoursUseCaseProvider).call(vendorId);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.toString()),
      (hours) => state = state.copyWith(
        isLoading: false,
        original: hours,
        current: hours,
        hasChanges: false,
      ),
    );
  }

  Future<bool> toggleStoreStatus() async {
    final current = state.current;
    if (current == null) return false;
    final nextValue = !current.isStoreOpen;
    final optimistic = current.copyWith(isStoreOpen: nextValue, updatedAt: DateTime.now());
    state = state.copyWith(current: optimistic, isTogglingStatus: true);
    final result = await ref.read(toggleStoreStatusUseCaseProvider).call(
          vendorId: current.vendorId,
          isOpen: nextValue,
        );
    return result.fold((f) {
      state = state.copyWith(
        current: current,
        isTogglingStatus: false,
        error: f.toString(),
      );
      return false;
    }, (_) {
      state = state.copyWith(isTogglingStatus: false, error: null);
      return true;
    });
  }

  void updateTemporaryMessage(String message) {
    final current = state.current;
    if (current == null) return;
    state = state.copyWith(
      current: current.copyWith(
        temporaryMessage: message.trim().isEmpty ? null : message.trim(),
      ),
      hasChanges: true,
    );
  }

  void toggleDay(DayOfWeek day) {
    _updateSchedule(day, (s) {
      final isOpen = !s.isOpen;
      final defaultOpen = const TimeOfDay(hour: 9, minute: 0);
      final defaultClose = const TimeOfDay(hour: 21, minute: 0);
      return s.copyWith(
        isOpen: isOpen,
        isClosed: !isOpen,
        openTime: s.openTime,
        closeTime: s.closeTime.hour == 0 && s.closeTime.minute == 0 ? defaultClose : s.closeTime,
      ).copyWith(openTime: s.openTime.hour == 0 && s.openTime.minute == 0 ? defaultOpen : s.openTime);
    });
  }

  void updateOpenTime(DayOfWeek day, TimeOfDay time) {
    _updateSchedule(day, (s) => s.copyWith(openTime: time, is24Hours: false));
  }

  void updateCloseTime(DayOfWeek day, TimeOfDay time) {
    _updateSchedule(day, (s) => s.copyWith(closeTime: time, is24Hours: false));
  }

  void toggle24Hours(DayOfWeek day) {
    _updateSchedule(
      day,
      (s) => s.is24Hours
          ? s.copyWith(is24Hours: false)
          : s.copyWith(
              is24Hours: true,
              openTime: const TimeOfDay(hour: 0, minute: 0),
              closeTime: const TimeOfDay(hour: 23, minute: 59),
              isOpen: true,
              isClosed: false,
            ),
    );
  }

  void applyPreset(StorePreset preset) {
    final current = state.current;
    if (current == null) return;
    final updated = current.copyWith(
      schedule: _applyPresetToSchedule(current.schedule, preset),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(current: updated, hasChanges: true);
  }

  void copyHoursTodays(DayOfWeek sourceDay, List<DayOfWeek> targetDays) {
    final current = state.current;
    if (current == null) return;
    final source = current.schedule.firstWhere((e) => e.day == sourceDay);
    final updated = current.schedule.map((e) {
      if (!targetDays.contains(e.day) || e.day == sourceDay) return e;
      return e.copyWith(
        isOpen: source.isOpen,
        isClosed: source.isClosed,
        is24Hours: source.is24Hours,
        openTime: source.openTime,
        closeTime: source.closeTime,
      );
    }).toList();
    state = state.copyWith(
      current: current.copyWith(schedule: updated, updatedAt: DateTime.now()),
      hasChanges: true,
    );
  }

  Future<bool> saveStoreHours() async {
    final current = state.current;
    if (current == null) return false;
    if (!StoreHoursValidator.isScheduleTimeOrderValid(current.schedule)) {
      state = state.copyWith(error: 'invalid');
      return false;
    }
    state = state.copyWith(isSaving: true, error: null);
    final result = await ref.read(updateStoreHoursUseCaseProvider).call(current);
    return result.fold((f) {
      state = state.copyWith(isSaving: false, error: f.toString());
      return false;
    }, (saved) {
      state = state.copyWith(
        isSaving: false,
        original: saved,
        current: saved,
        hasChanges: false,
      );
      return true;
    });
  }

  void discardChanges() {
    state = state.copyWith(current: state.original, hasChanges: false);
  }

  StoreStatusEntity computeStoreStatus(BuildContext context) {
    final current = state.current;
    if (current == null) {
      return StoreStatusEntity(
        isOpen: false,
        currentDayHours: null,
        nextOpenDay: null,
        statusLabel: '',
        nextOpenLabel: null,
      );
    }
    final now = TimeOfDay.now();
    final day = _dayFromDateTime(DateTime.now());
    final today = current.schedule.firstWhere((e) => e.day == day);
    final openNow = current.isStoreOpen && today.isOpen && !_isClosedNow(today, now);
    DayScheduleEntity? next;
    if (!openNow) {
      for (var i = 1; i <= 7; i++) {
        final d = egyptWeekOrder[(egyptWeekOrder.indexOf(day) + i) % 7];
        final candidate = current.schedule.firstWhere((e) => e.day == d);
        if (candidate.isOpen) {
          next = candidate;
          break;
        }
      }
    }
    return StoreStatusEntity(
      isOpen: openNow,
      currentDayHours: today,
      nextOpenDay: next,
      statusLabel: openNow ? 'open' : 'closed',
      nextOpenLabel: next == null ? null : '${_dayLabel(next.day)}-${next.openTime.formatForStore(context)}',
    );
  }

  void _updateSchedule(DayOfWeek day, DayScheduleEntity Function(DayScheduleEntity) update) {
    final current = state.current;
    if (current == null) return;
    final schedule = current.schedule.map((e) => e.day == day ? update(e) : e).toList();
    state = state.copyWith(
      current: current.copyWith(schedule: schedule, updatedAt: DateTime.now()),
      hasChanges: true,
    );
  }
}

bool _isClosedNow(DayScheduleEntity schedule, TimeOfDay now) {
  if (!schedule.isOpen) return true;
  if (schedule.is24Hours) return false;
  final n = now.hour * 60 + now.minute;
  final o = schedule.openTime.hour * 60 + schedule.openTime.minute;
  final c = schedule.closeTime.hour * 60 + schedule.closeTime.minute;
  return n < o || n > c;
}

List<DayScheduleEntity> _applyPresetToSchedule(List<DayScheduleEntity> current, StorePreset preset) {
  TimeOfDay open;
  TimeOfDay close;
  bool Function(DayOfWeek day) isOpenFn;
  switch (preset) {
    case StorePreset.standard:
      open = const TimeOfDay(hour: 9, minute: 0);
      close = const TimeOfDay(hour: 18, minute: 0);
      isOpenFn = (d) => d != DayOfWeek.friday;
    case StorePreset.extended:
      open = const TimeOfDay(hour: 9, minute: 0);
      close = const TimeOfDay(hour: 23, minute: 0);
      isOpenFn = (d) => d != DayOfWeek.friday;
    case StorePreset.morningOnly:
      open = const TimeOfDay(hour: 8, minute: 0);
      close = const TimeOfDay(hour: 14, minute: 0);
      isOpenFn = (d) => d != DayOfWeek.friday;
    case StorePreset.fullWeek:
      open = const TimeOfDay(hour: 9, minute: 0);
      close = const TimeOfDay(hour: 22, minute: 0);
      isOpenFn = (_) => true;
    case StorePreset.weekdaysOnly:
    case StorePreset.withoutFriday:
      open = const TimeOfDay(hour: 9, minute: 0);
      close = const TimeOfDay(hour: 21, minute: 0);
      isOpenFn = (d) => d != DayOfWeek.friday;
  }
  return current
      .map(
        (d) => d.copyWith(
          isOpen: isOpenFn(d.day),
          isClosed: !isOpenFn(d.day),
          is24Hours: false,
          openTime: open,
          closeTime: close,
        ),
      )
      .toList();
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

String _dayLabel(DayOfWeek day) {
  return switch (day) {
    DayOfWeek.saturday => 'Sat',
    DayOfWeek.sunday => 'Sun',
    DayOfWeek.monday => 'Mon',
    DayOfWeek.tuesday => 'Tue',
    DayOfWeek.wednesday => 'Wed',
    DayOfWeek.thursday => 'Thu',
    DayOfWeek.friday => 'Fri',
  };
}

