import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/government_entity.dart';
import '../repositories/government_repository.dart';

class GetGovernmentByIdUseCase {
  const GetGovernmentByIdUseCase(this._repository);

  final GovernmentRepository _repository;

  Future<Either<Failure, GovernmentEntity>> call(int id) {
    return _repository.getGovernmentById(id);
  }
}
