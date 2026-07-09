import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/government_entity.dart';
import '../repositories/government_repository.dart';

class GetGovernmentsUseCase {
  const GetGovernmentsUseCase(this._repository);

  final GovernmentRepository _repository;

  Future<Either<Failure, PaginatedResult<GovernmentEntity>>> call({
    required int page,
    required int pageSize,
  }) {
    return _repository.getGovernments(page: page, pageSize: pageSize);
  }
}
