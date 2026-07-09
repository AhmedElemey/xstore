import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_token_pair.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthTokenPair>> call(String token) {
    return _repository.refreshToken(token);
  }
}
