import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class DeleteNotificationUseCase {
  DeleteNotificationUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Either<Failure, Unit>> call(String notificationId) =>
      _repository.deleteNotification(notificationId);
}
