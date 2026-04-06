import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/social_auth_result.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  const GoogleSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, SocialAuthResult>> call() =>
      _repository.signInWithGoogle();
}
