import '../../../../core/mock/mock_notifications.dart';
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

  @override
  Future<List<NotificationEntity>> fetchPage({
    required UserRole role,
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = _base(role);
    final start = page * pageSize;
    if (start >= all.length) return [];
    return all.sublist(
      start,
      start + pageSize > all.length ? all.length : start + pageSize,
    );
  }

  @override
  Future<int> unreadCount(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _base(role).where((e) => !e.isRead).length;
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _readOverride[id] = true;
  }

  @override
  Future<void> markAllRead(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final e in _base(role)) {
      _readOverride[e.id] = true;
    }
  }

  @override
  Future<void> markUnread(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _readOverride[id] = false;
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _deleted.add(id);
    _readOverride.remove(id);
  }

}
