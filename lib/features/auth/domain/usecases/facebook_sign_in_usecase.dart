import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/social_auth_result.dart';
import '../repositories/auth_repository.dart';

class FacebookSignInUseCase {
  const FacebookSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, SocialAuthResult>> call() =>
      _repository.signInWithFacebook();
}
