import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Unit>> call() {
    return _repository.deleteAccount();
  }
}
