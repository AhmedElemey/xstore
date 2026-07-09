import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/government_entity.dart';

abstract interface class GovernmentRepository {
  Future<Either<Failure, PaginatedResult<GovernmentEntity>>> getGovernments({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, GovernmentEntity>> getGovernmentById(int id);
}
