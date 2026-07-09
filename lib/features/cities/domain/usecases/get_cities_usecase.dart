import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/city_entity.dart';
import '../repositories/city_repository.dart';

class GetCitiesUseCase {
  const GetCitiesUseCase(this._repository);

  final CityRepository _repository;

  Future<Either<Failure, PaginatedResult<CityEntity>>> call({
    required int page,
    required int pageSize,
  }) {
    return _repository.getCities(page: page, pageSize: pageSize);
  }
}
