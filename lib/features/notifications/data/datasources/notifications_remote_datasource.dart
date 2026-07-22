import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/register_device_token_request.dart';

abstract class NotificationsRemoteDataSource {
  Future<PaginatedResult<NotificationEntity>> fetchPage({
    required UserRole role,
    required int page,
    required int pageSize,
  });

  Future<int> unreadCount(UserRole role);

  Future<void> markRead(String id);

  Future<void> markAllRead(UserRole role);

  Future<void> markUnread(String id);

  Future<void> deleteNotification(String id);

  Future<void> registerDeviceToken(RegisterDeviceTokenRequest request);

  Future<void> unregisterDeviceToken(RegisterDeviceTokenRequest request);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // Backend notifications endpoint only accepts role=ALL; per-role filtering
  // (vendor/consumer/courier) is not implemented server-side as of 2026-07-23.
  // UserRole param kept for future use.
  String _roleParam(UserRole role) => 'ALL';

  @override
  Future<PaginatedResult<NotificationEntity>> fetchPage({
    required UserRole role,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: {
          'role': _roleParam(role),
          // Notifier's `page` is 0-based; wire contract is 1-based
          // (page=1 in the collection example) — translate only here.
          'page': page + 1,
          'pageSize': pageSize,
        },
        options: ApiAuthHeaders.authenticated(),
      );
      return _parsePaginatedResponse(
        response.data,
        page: page,
        pageSize: pageSize,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<int> unreadCount(UserRole role) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notificationsUnreadCount,
        queryParameters: {'role': _roleParam(role)},
        options: ApiAuthHeaders.authenticated(),
      );
      // CONFIRMED live (2026-07-23): bare integer body, e.g. `0`.
      final data = response.data;
      if (data is num) return data.toInt();
      return 0;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _dio.put<void>(
        ApiEndpoints.notificationMarkRead(id),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> markAllRead(UserRole role) async {
    try {
      await _dio.put<void>(
        ApiEndpoints.notificationsReadAll,
        queryParameters: {'role': _roleParam(role)},
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> markUnread(String id) async {
    try {
      await _dio.put<void>(
        ApiEndpoints.notificationMarkUnread(id),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete<void>(
        ApiEndpoints.notificationById(id),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> registerDeviceToken(RegisterDeviceTokenRequest request) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.notificationsDeviceToken,
        data: request.toJson(),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> unregisterDeviceToken(RegisterDeviceTokenRequest request) async {
    try {
      await _dio.delete<void>(
        ApiEndpoints.notificationsDeviceToken,
        data: request.toJson(),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ---- JSON parsing (hand-written; no separate Model class layer — the
  // typedef-only NotificationModel pattern stays). ----

  PaginatedResult<NotificationEntity> _parsePaginatedResponse(
    dynamic data, {
    required int page,
    required int pageSize,
  }) {
    if (data is! Map) {
      return PaginatedResult(
        items: const [],
        page: page,
        pageSize: pageSize,
        totalCount: 0,
      );
    }

    final m = Map<String, dynamic>.from(data);
    final rawItems = m['items'] as List<dynamic>? ?? [];
    final items = <NotificationEntity>[];
    for (final e in rawItems) {
      if (e is! Map) continue;
      final wireItem = Map<String, dynamic>.from(e);
      try {
        items.add(_parseNotification(wireItem));
      } catch (err, st) {
        if (kDebugMode) {
          debugPrint(
            'Notifications: skipped malformed item $wireItem: $err\n$st',
          );
        }
      }
    }

    // Confirmed live envelope (2026-07-23):
    // {items, totalCount, page, pageSize, totalPages} — page is 1-based on wire.
    final wirePage = _readInt(m['page']) ?? (page + 1);
    final wirePageSize = _readInt(m['pageSize']) ?? pageSize;

    return PaginatedResult(
      items: items,
      page: wirePage - 1,
      pageSize: wirePageSize,
      totalCount: _readInt(m['totalCount']) ?? 0,
      totalPages: _readInt(m['totalPages']) ?? 0,
    );
  }

  int? _readInt(dynamic value) => value is num ? value.toInt() : null;

  String? _optString(Map<String, dynamic> m, String key, {String? altKey}) {
    String? pick(dynamic v) {
      if (v == null) return null;
      final s = v is String ? v : v.toString();
      final trimmed = s.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return pick(m[key]) ?? (altKey != null ? pick(m[altKey]) : null);
  }

  int? _optInt(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? _optDouble(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  NotificationEntity _parseNotification(Map<String, dynamic> m) {
    return NotificationEntity(
      id: (m['id'] ?? '').toString(),
      type: _typeFromWire(m['type']),
      priority: _priorityFromWire(m['priority']),
      title: (m['title'] ?? '').toString(),
      body: (m['body'] ?? m['message'] ?? '').toString(),
      imageUrl: _optString(m, 'imageUrl'),
      actionRoute: _optString(m, 'actionRoute'),
      actionData: m['actionData'] is Map
          ? Map<String, dynamic>.from(m['actionData'] as Map)
          : null,
      isRead: m['isRead'] == true || m['read'] == true,
      createdAt:
          DateTime.tryParse((m['createdAt'] ?? '').toString()) ?? DateTime.now(),
      orderId: _optString(m, 'orderId'),
      listingId: _optString(m, 'listingId'),
      reviewId: _optString(m, 'reviewId'),
      senderId: _optString(m, 'senderId'),
      senderName: _optString(m, 'senderName'),
      senderAvatar: _optString(m, 'senderAvatar'),
      discountPercent: _optInt(m, 'discountPercent'),
      priceDropAmount: _optDouble(m, 'priceDropAmount'),
    );
  }

  // String-name matching works for string payloads. Ordinal mapping needs
  // confirmation from the backend before we can map numeric codes correctly —
  // until then, numeric values fall back to the default rather than guessing.
  NotificationType _typeFromWire(dynamic raw) {
    // Backend sends type/priority as int enum ordinals on at least some real
    // records (seed account observed); do not infer ordinal → member mapping.
    if (raw is num) return NotificationType.systemAnnouncement;
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return NotificationType.systemAnnouncement;
    for (final t in NotificationType.values) {
      if (t.name.toLowerCase() == s.toLowerCase()) return t;
    }
    return NotificationType.systemAnnouncement;
  }

  NotificationPriority _priorityFromWire(dynamic raw) {
    // See _typeFromWire — numeric priority codes are intentionally unmapped.
    if (raw is num) return NotificationPriority.normal;
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return NotificationPriority.normal;
    for (final p in NotificationPriority.values) {
      if (p.name.toLowerCase() == s.toLowerCase()) return p;
    }
    return NotificationPriority.normal;
  }
}
