import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required UserRole role,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, int>> unreadCount(UserRole role);

  Future<Either<Failure, Unit>> markRead(String notificationId);

  Future<Either<Failure, Unit>> markAllRead(UserRole role);

  Future<Either<Failure, Unit>> markUnread(String notificationId);

  Future<Either<Failure, Unit>> deleteNotification(String notificationId);
}
