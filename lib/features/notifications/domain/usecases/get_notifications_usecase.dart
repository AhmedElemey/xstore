import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Either<Failure, List<NotificationEntity>>> call({
    required UserRole role,
    required int page,
    required int pageSize,
  }) =>
      _repository.getNotifications(role: role, page: page, pageSize: pageSize);
}
