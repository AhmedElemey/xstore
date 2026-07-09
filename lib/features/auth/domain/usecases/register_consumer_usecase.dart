import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/consumer_register_params.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterConsumerUseCase {
  const RegisterConsumerUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(ConsumerRegisterParams params) {
    return _repository.registerConsumer(params);
  }
}
