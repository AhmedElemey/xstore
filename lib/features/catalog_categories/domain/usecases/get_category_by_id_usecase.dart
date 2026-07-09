import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/catalog_category_entity.dart';
import '../repositories/catalog_category_repository.dart';

class GetCategoryByIdUseCase {
  const GetCategoryByIdUseCase(this._repository);

  final CatalogCategoryRepository _repository;

  Future<Either<Failure, CatalogCategoryEntity>> call(int id) {
    return _repository.getCategoryById(id);
  }
}
