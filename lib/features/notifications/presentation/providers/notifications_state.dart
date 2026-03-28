import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_entity.dart';

part 'notifications_state.freezed.dart';

enum NotificationFilter {
  all,
  orders,
  deals,
  listings,
  messages,
  system,
}

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default([]) List<NotificationEntity> notifications,
    @Default([]) List<NotificationEntity> filteredNotifications,
    @Default([]) List<NotificationGroup> groups,
    @Default(NotificationFilter.all) NotificationFilter selectedFilter,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(0) int page,
    String? error,
    @Default(false) bool markAllReadAnimating,
  }) = _NotificationsState;
}
