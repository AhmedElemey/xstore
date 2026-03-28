import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required UserRole role,
    required int page,
    required int pageSize,
  }) async {
    try {
      return Right(
        await _remote.fetchPage(role: role, page: page, pageSize: pageSize),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> unreadCount(UserRole role) async {
    try {
      return Right(await _remote.unreadCount(role));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead(String notificationId) async {
    try {
      await _remote.markRead(notificationId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead(UserRole role) async {
    try {
      await _remote.markAllRead(role);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markUnread(String notificationId) async {
    try {
      await _remote.markUnread(notificationId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _remote.deleteNotification(notificationId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
