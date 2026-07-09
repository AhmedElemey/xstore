import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_category_entity.dart';
import '../repositories/store_category_repository.dart';

class GetStoreCategoryByIdUseCase {
  const GetStoreCategoryByIdUseCase(this._repository);

  final StoreCategoryRepository _repository;

  Future<Either<Failure, StoreCategoryEntity>> call(int id) {
    return _repository.getStoreCategoryById(id);
  }
}
