import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/vendor_register_params.dart';
import '../repositories/auth_repository.dart';

class RegisterVendorUseCase {
  const RegisterVendorUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(VendorRegisterParams params) {
    return _repository.registerVendor(params);
  }
}
