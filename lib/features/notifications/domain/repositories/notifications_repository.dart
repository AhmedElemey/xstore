import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, PaginatedResult<NotificationEntity>>> getNotifications({
    required UserRole role,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, int>> unreadCount(UserRole role);

  Future<Either<Failure, Unit>> markRead(String notificationId);

  Future<Either<Failure, Unit>> markAllRead(UserRole role);

  Future<Either<Failure, Unit>> markUnread(String notificationId);

  Future<Either<Failure, Unit>> deleteNotification(String notificationId);

  Future<Either<Failure, Unit>> registerDeviceToken(String token);

  Future<Either<Failure, Unit>> unregisterDeviceToken(String token);
}
