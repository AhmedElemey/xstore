import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/city_entity.dart';
import '../repositories/city_repository.dart';

class GetCityByIdUseCase {
  const GetCityByIdUseCase(this._repository);

  final CityRepository _repository;

  Future<Either<Failure, CityEntity>> call(int id) {
    return _repository.getCityById(id);
  }
}
