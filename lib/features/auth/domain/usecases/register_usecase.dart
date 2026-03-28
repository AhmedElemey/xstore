import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.register(email: email, password: password);
  }
}
