import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/city_entity.dart';

abstract interface class CityRepository {
  Future<Either<Failure, PaginatedResult<CityEntity>>> getCities({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, CityEntity>> getCityById(int id);
}
