import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/notification_entity.dart';
import 'notifications_dependencies.dart';
import 'notifications_state.dart';

part 'notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  static const _pageSize = 10;

  final Map<String, Timer> _deleteTimers = {};

  @override
  NotificationsState build() {
    ref.onDispose(() {
      for (final t in _deleteTimers.values) {
        t.cancel();
      }
      _deleteTimers.clear();
    });
    ref.listen(authProvider, (prev, next) {
      if (next.isLoading) return;
      if (next.valueOrNull != null) {
        Future.microtask(fetchNotifications);
      } else {
        Future.microtask(() => state = const NotificationsState());
      }
    });
    return const NotificationsState();
  }

  UserRole get _role =>
      ref.read(authProvider).valueOrNull?.role ?? UserRole.consumer;

  bool _matchesFilter(NotificationEntity e, NotificationFilter f) {
    final role = _role;
    switch (f) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.orders:
        if (role == UserRole.vendor) {
          return {
            NotificationType.newOrder,
            NotificationType.orderCancelledVendor,
            NotificationType.paymentReceived,
          }.contains(e.type);
        }
        return {
          NotificationType.orderPlaced,
          NotificationType.orderConfirmed,
          NotificationType.orderShipped,
          NotificationType.orderDelivered,
          NotificationType.orderCancelled,
          NotificationType.reviewReply,
        }.contains(e.type);
      case NotificationFilter.deals:
        if (role == UserRole.vendor) return false;
        return {
          NotificationType.priceDrop,
          NotificationType.flashSale,
          NotificationType.promotionalOffer,
          NotificationType.backInStock,
        }.contains(e.type);
      case NotificationFilter.listings:
        if (role == UserRole.consumer) return false;
        return {
          NotificationType.listingApproved,
          NotificationType.listingRejected,
          NotificationType.lowStock,
          NotificationType.newReview,
        }.contains(e.type);
      case NotificationFilter.messages:
        return e.type == NotificationType.newMessage;
      case NotificationFilter.system:
        return {
          NotificationType.accountVerified,
          NotificationType.systemAnnouncement,
          NotificationType.securityAlert,
        }.contains(e.type);
    }
  }

  List<NotificationGroup> _groupByDate(List<NotificationEntity> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek =
        today.subtract(Duration(days: today.weekday - DateTime.monday));

    final todayL = <NotificationEntity>[];
    final yestL = <NotificationEntity>[];
    final weekL = <NotificationEntity>[];
    final earlierL = <NotificationEntity>[];

    for (final e in items) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      if (d == today) {
        todayL.add(e);
      } else if (d == yesterday) {
        yestL.add(e);
      } else if (!d.isBefore(startOfWeek) && d.isBefore(today)) {
        weekL.add(e);
      } else {
        earlierL.add(e);
      }
    }

    final out = <NotificationGroup>[];
    if (todayL.isNotEmpty) {
      out.add(
        NotificationGroup(
          label: AppStrings.notificationsGroupToday,
          notifications: todayL,
        ),
      );
    }
    if (yestL.isNotEmpty) {
      out.add(
        NotificationGroup(
          label: AppStrings.notificationsGroupYesterday,
          notifications: yestL,
        ),
      );
    }
    if (weekL.isNotEmpty) {
      out.add(
        NotificationGroup(
          label: AppStrings.notificationsGroupThisWeek,
          notifications: weekL,
        ),
      );
    }
    if (earlierL.isNotEmpty) {
      out.add(
        NotificationGroup(
          label: AppStrings.notificationsGroupEarlier,
          notifications: earlierL,
        ),
      );
    }
    return out;
  }

  void _applyFilterAndGroups() {
    final filtered = state.notifications
        .where((e) => _matchesFilter(e, state.selectedFilter))
        .toList();
    state = state.copyWith(
      filteredNotifications: filtered,
      groups: _groupByDate(filtered),
    );
  }

  Future<void> fetchNotifications() async {
    final role = _role;
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 0,
      notifications: [],
      hasMore: true,
    );
    final listR =
        await ref.read(getNotificationsUseCaseProvider).call(
              role: role,
              page: 0,
              pageSize: _pageSize,
            );
    final countR = await ref.read(notificationsRepositoryProvider).unreadCount(role);
    listR.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.toString()),
      (list) {
        countR.fold(
          (fc) =>
              state = state.copyWith(isLoading: false, error: fc.toString()),
          (count) {
            state = state.copyWith(
              isLoading: false,
              notifications: list,
              unreadCount: count,
              hasMore: list.length >= _pageSize,
              page: 0,
            );
            _applyFilterAndGroups();
          },
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final role = _role;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    final r = await ref.read(getNotificationsUseCaseProvider).call(
          role: role,
          page: nextPage,
          pageSize: _pageSize,
        );
    r.fold(
      (f) => state = state.copyWith(isLoadingMore: false, error: f.toString()),
      (more) {
        final merged = [...state.notifications, ...more];
        state = state.copyWith(
          isLoadingMore: false,
          notifications: merged,
          page: nextPage,
          hasMore: more.length >= _pageSize,
        );
        _applyFilterAndGroups();
      },
    );
  }

  void applyFilter(NotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
    _applyFilterAndGroups();
  }

  void markAsRead(String notificationId) {
    final wasUnread = state.notifications.any(
      (e) => e.id == notificationId && !e.isRead,
    );
    final updated = state.notifications
        .map(
          (e) =>
              e.id == notificationId ? e.copyWith(isRead: true) : e,
        )
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount:
          wasUnread ? (state.unreadCount - 1).clamp(0, 1 << 30) : state.unreadCount,
    );
    _applyFilterAndGroups();
    unawaited(ref.read(markReadUseCaseProvider).call(notificationId));
  }

  void markAsUnread(String notificationId) {
    final wasRead = state.notifications.any(
      (e) => e.id == notificationId && e.isRead,
    );
    final updated = state.notifications
        .map(
          (e) =>
              e.id == notificationId ? e.copyWith(isRead: false) : e,
        )
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount:
          wasRead ? state.unreadCount + 1 : state.unreadCount,
    );
    _applyFilterAndGroups();
    unawaited(ref.read(markUnreadUseCaseProvider).call(notificationId));
  }

  Future<void> markAllRead() async {
    final role = _role;
    state = state.copyWith(
      markAllReadAnimating: true,
      notifications:
          state.notifications.map((e) => e.copyWith(isRead: true)).toList(),
      unreadCount: 0,
    );
    _applyFilterAndGroups();
    await ref.read(markAllReadUseCaseProvider).call(role);
    await Future<void>.delayed(const Duration(milliseconds: 360));
    state = state.copyWith(markAllReadAnimating: false);
  }

  void onDeleteConfirmed(NotificationEntity entity) {
    final id = entity.id;
    _deleteTimers[id]?.cancel();
    final wasUnread = !entity.isRead;
    state = state.copyWith(
      notifications: state.notifications.where((e) => e.id != id).toList(),
      unreadCount:
          wasUnread ? (state.unreadCount - 1).clamp(0, 1 << 30) : state.unreadCount,
    );
    _applyFilterAndGroups();
    _deleteTimers[id] = Timer(const Duration(seconds: 5), () {
      _deleteTimers.remove(id);
      unawaited(ref.read(deleteNotificationUseCaseProvider).call(id));
    });
  }

  void cancelDeleteUndo(NotificationEntity entity) {
    final id = entity.id;
    _deleteTimers[id]?.cancel();
    _deleteTimers.remove(id);
    final merged = [...state.notifications, entity]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(
      notifications: merged,
      unreadCount: !entity.isRead ? state.unreadCount + 1 : state.unreadCount,
    );
    _applyFilterAndGroups();
  }

  Future<void> refreshNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    await fetchNotifications();
  }

  int unreadInFilter(NotificationFilter filter) {
    return state.notifications
        .where((e) => _matchesFilter(e, filter) && !e.isRead)
        .length;
  }
}
