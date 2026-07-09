import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/catalog_category_entity.dart';
import '../repositories/catalog_category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CatalogCategoryRepository _repository;

  Future<Either<Failure, List<CatalogCategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
