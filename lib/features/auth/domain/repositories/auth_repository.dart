import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity?>> restoreSession();

  Future<Either<Failure, UserEntity>> login(LoginParams params);

  Future<Either<Failure, UserEntity>> register(RegisterParams params);

  Future<Either<Failure, Unit>> logout();
}
