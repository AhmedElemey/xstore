import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/notifications_repository.dart';

class MarkAllReadUseCase {
  MarkAllReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Either<Failure, Unit>> call(UserRole role) =>
      _repository.markAllRead(role);
}
