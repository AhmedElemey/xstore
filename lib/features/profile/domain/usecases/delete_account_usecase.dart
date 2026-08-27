import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String password,
    required String confirmationText,
  }) {
    return _repository.deleteAccount(
      password: password,
      confirmationText: confirmationText,
    );
  }
}
