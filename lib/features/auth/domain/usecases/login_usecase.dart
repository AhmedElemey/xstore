import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_params.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(params);
  }
}
