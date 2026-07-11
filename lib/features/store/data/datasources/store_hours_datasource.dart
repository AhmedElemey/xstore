import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_store_hours.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/legacy_route_options.dart';
import '../../domain/entities/day_schedule_entity.dart';
import '../models/day_schedule_model.dart';
import '../models/store_hours_model.dart';

abstract interface class StoreHoursDataSource {
  Future<StoreHoursModel> getStoreHours(String vendorId);
  Future<StoreHoursModel> updateStoreHours(StoreHoursModel hours);
  Future<bool> toggleStoreStatus(String vendorId, bool isOpen);
}

class StoreHoursDataSourceImpl implements StoreHoursDataSource {
  StoreHoursDataSourceImpl([Dio? dio]) : _dio = dio;

  final Dio? _dio;
  static StoreHoursModel _cache = StoreHoursModel.fromEntity(mockStoreHours);

  static bool _isStoreHoursRouteMissing(DioException e) =>
      e.response?.statusCode == 404;

  Options get _legacyOptions => LegacyRouteOptions.allowNotFound();

  StoreHoursModel _defaultHoursFor(String vendorId) {
    return StoreHoursModel.fromEntity(
      mockStoreHours.copyWith(vendorId: vendorId, updatedAt: DateTime.now()),
    );
  }

  StoreHoursModel _fallbackHours(String vendorId) {
    if (_cache.vendorId == vendorId) return _cache;
    return _defaultHoursFor(vendorId);
  }

  @override
  Future<StoreHoursModel> getStoreHours(String vendorId) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_cache);
    }
    final dio = _dio;
    if (dio == null) {
      throw const ServerException('Store hours API client is not configured');
    }
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.vendorStoreHours(vendorId),
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        final fallback = _fallbackHours(vendorId);
        _cache = fallback;
        return fallback;
      }
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty store hours response');
      }
      final model = _fromMap(data);
      _cache = model;
      return model;
    } on DioException catch (e) {
      if (_isStoreHoursRouteMissing(e)) {
        final fallback = _fallbackHours(vendorId);
        _cache = fallback;
        return fallback;
      }
      throw ServerException(e.message ?? 'Failed to fetch store hours');
    }
  }

  @override
  Future<StoreHoursModel> updateStoreHours(StoreHoursModel hours) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _cache = hours;
      return hours;
    }
    final dio = _dio;
    if (dio == null) {
      throw const ServerException('Store hours API client is not configured');
    }
    try {
      final response = await dio.put<Map<String, dynamic>>(
        ApiEndpoints.vendorStoreHours(hours.vendorId),
        data: _toMap(hours),
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        _cache = hours;
        return hours;
      }
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty store hours response');
      }
      final model = _fromMap(data);
      _cache = model;
      return model;
    } on DioException catch (e) {
      if (_isStoreHoursRouteMissing(e)) {
        _cache = hours;
        return hours;
      }
      throw ServerException(e.message ?? 'Failed to save store hours');
    }
  }

  @override
  Future<bool> toggleStoreStatus(String vendorId, bool isOpen) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _cache = StoreHoursModel(
        vendorId: _cache.vendorId,
        isStoreOpen: isOpen,
        temporaryMessage: _cache.temporaryMessage,
        schedule: _cache.schedule,
        updatedAt: DateTime.now(),
      );
      return isOpen;
    }
    final dio = _dio;
    if (dio == null) {
      throw const ServerException('Store hours API client is not configured');
    }
    try {
      final response = await dio.patch<void>(
        ApiEndpoints.vendorStoreStatus(vendorId),
        data: {'isStoreOpen': isOpen},
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        final base = _fallbackHours(vendorId);
        _cache = StoreHoursModel(
          vendorId: vendorId,
          isStoreOpen: isOpen,
          temporaryMessage: base.temporaryMessage,
          schedule: base.schedule,
          updatedAt: DateTime.now(),
        );
        return isOpen;
      }
      _cache = StoreHoursModel(
        vendorId: _cache.vendorId == vendorId ? _cache.vendorId : vendorId,
        isStoreOpen: isOpen,
        temporaryMessage: _cache.temporaryMessage,
        schedule: _cache.schedule,
        updatedAt: DateTime.now(),
      );
      return isOpen;
    } on DioException catch (e) {
      if (_isStoreHoursRouteMissing(e)) {
        final base = _fallbackHours(vendorId);
        _cache = StoreHoursModel(
          vendorId: vendorId,
          isStoreOpen: isOpen,
          temporaryMessage: base.temporaryMessage,
          schedule: base.schedule,
          updatedAt: DateTime.now(),
        );
        return isOpen;
      }
      throw ServerException(e.message ?? 'Failed to toggle store status');
    }
  }

  StoreHoursModel _fromMap(Map<String, dynamic> json) {
    final rawSchedule = (json['schedule'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final schedule = rawSchedule.map(_dayFromMap).toList();
    return StoreHoursModel(
      vendorId: (json['vendorId'] ?? '').toString(),
      isStoreOpen: json['isStoreOpen'] == true,
      temporaryMessage: json['temporaryMessage'] as String?,
      schedule: schedule,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  DayScheduleModel _dayFromMap(Map<String, dynamic> json) {
    final open = _parseTime((json['openTime'] ?? '09:00').toString());
    final close = _parseTime((json['closeTime'] ?? '18:00').toString());
    return DayScheduleModel(
      day: _parseDay((json['day'] ?? '').toString()),
      isOpen: json['isOpen'] == true,
      openHour: open.$1,
      openMinute: open.$2,
      closeHour: close.$1,
      closeMinute: close.$2,
      is24Hours: json['is24Hours'] == true,
      isClosed: json['isClosed'] == true,
    );
  }

  Map<String, dynamic> _toMap(StoreHoursModel model) => {
        'vendorId': model.vendorId,
        'isStoreOpen': model.isStoreOpen,
        'temporaryMessage': model.temporaryMessage,
        'updatedAt': model.updatedAt.toIso8601String(),
        'schedule': model.schedule
            .map(
              (e) => {
                'day': e.day.name,
                'isOpen': e.isOpen,
                'openTime': _fmt(e.openHour, e.openMinute),
                'closeTime': _fmt(e.closeHour, e.closeMinute),
                'is24Hours': e.is24Hours,
                'isClosed': e.isClosed,
              },
            )
            .toList(),
      };

  DayOfWeek _parseDay(String raw) {
    for (final day in DayOfWeek.values) {
      if (day.name == raw.toLowerCase()) return day;
    }
    return DayOfWeek.saturday;
  }

  (int, int) _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return (9, 0);
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    return (hour.clamp(0, 23), minute.clamp(0, 59));
  }

  String _fmt(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
