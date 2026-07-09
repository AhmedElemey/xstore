import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_notifications.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationEntity>> fetchPage({
    required UserRole role,
    required int page,
    required int pageSize,
  });

  Future<int> unreadCount(UserRole role);

  Future<void> markRead(String id);

  Future<void> markAllRead(UserRole role);

  Future<void> markUnread(String id);

  Future<void> deleteNotification(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // ---- mock-only in-memory overlay state ----
  final Set<String> _deleted = {};
  final Map<String, bool> _readOverride = {};

  List<NotificationEntity> _base(UserRole role) {
    final raw = mockNotificationsForRole(role, anchor: DateTime.now())
        .where((e) => !_deleted.contains(e.id))
        .toList();
    return raw
        .map(
          (e) => _readOverride.containsKey(e.id)
              ? e.copyWith(isRead: _readOverride[e.id]!)
              : e,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ASSUMPTION: query value for `role` — UserRole enum is {vendor, consumer},
  // no "ALL" member. The collection's example `role=ALL` means "both roles";
  // this app always requests a specific signed-in user's role, so ALL is
  // never sent. Using role.name.toUpperCase() -> 'CONSUMER' / 'VENDOR'. If
  // the backend expects a different token, calls will 400 — that's the
  // signal to revisit this mapping.
  String _roleParam(UserRole role) => role.name.toUpperCase();

  @override
  Future<List<NotificationEntity>> fetchPage({
    required UserRole role,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final all = _base(role);
      final start = page * pageSize;
      if (start >= all.length) return [];
      return all.sublist(
        start,
        start + pageSize > all.length ? all.length : start + pageSize,
      );
    }
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
      return _unwrapList(response.data).map(_parseNotification).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<int> unreadCount(UserRole role) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return _base(role).where((e) => !e.isRead).length;
    }
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notificationsUnreadCount,
        queryParameters: {'role': _roleParam(role)},
        options: ApiAuthHeaders.authenticated(),
      );
      // ASSUMPTION: response is either a bare int, or {"count"|
      // "unreadCount"|"total": N}. Adjust once a live response is seen.
      final data = response.data;
      if (data is num) return data.toInt();
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final v = m['count'] ?? m['unreadCount'] ?? m['total'];
        if (v is num) return v.toInt();
      }
      return 0;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _readOverride[id] = true;
      return;
    }
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
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      for (final e in _base(role)) {
        _readOverride[e.id] = true;
      }
      return;
    }
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
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _readOverride[id] = false;
      return;
    }
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
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _deleted.add(id);
      _readOverride.remove(id);
      return;
    }
    try {
      await _dio.delete<void>(
        ApiEndpoints.notificationById(id),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ---- JSON parsing (hand-written; no separate Model class layer — the
  // typedef-only NotificationModel pattern stays). ----

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final items = m['items'] ?? m['data'] ?? m['results'] ?? m['notifications'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  NotificationEntity _parseNotification(Map<String, dynamic> m) {
    return NotificationEntity(
      id: (m['id'] ?? '').toString(),
      type: _typeFromWire((m['type'] ?? '').toString()),
      priority: _priorityFromWire((m['priority'] ?? '').toString()),
      title: (m['title'] ?? '').toString(),
      body: (m['body'] ?? m['message'] ?? '').toString(),
      imageUrl: (m['imageUrl'] as String?)?.isNotEmpty == true
          ? m['imageUrl'] as String
          : null,
      actionRoute: m['actionRoute'] as String?,
      actionData: m['actionData'] is Map
          ? Map<String, dynamic>.from(m['actionData'] as Map)
          : null,
      isRead: m['isRead'] == true || m['read'] == true,
      createdAt:
          DateTime.tryParse((m['createdAt'] ?? '').toString()) ?? DateTime.now(),
      orderId: m['orderId']?.toString(),
      listingId: m['listingId']?.toString(),
      reviewId: m['reviewId']?.toString(),
      senderId: m['senderId']?.toString(),
      senderName: m['senderName']?.toString(),
      senderAvatar: m['senderAvatar']?.toString(),
      discountPercent: (m['discountPercent'] as num?)?.toInt(),
      priceDropAmount: (m['priceDropAmount'] as num?)?.toDouble(),
    );
  }

  // ASSUMPTION: wire `type`/`priority` are the enum name strings (camelCase,
  // e.g. "orderPlaced", "priceDrop") matching NotificationType's Dart
  // identifiers, matched case-insensitively. If the backend sends
  // PascalCase or SCREAMING_CASE this still resolves; if it sends entirely
  // different tokens, adjust the matching here (not the enum itself).
  NotificationType _typeFromWire(String raw) {
    for (final t in NotificationType.values) {
      if (t.name.toLowerCase() == raw.toLowerCase()) return t;
    }
    return NotificationType.systemAnnouncement;
  }

  NotificationPriority _priorityFromWire(String raw) {
    for (final p in NotificationPriority.values) {
      if (p.name.toLowerCase() == raw.toLowerCase()) return p;
    }
    return NotificationPriority.normal;
  }
}
