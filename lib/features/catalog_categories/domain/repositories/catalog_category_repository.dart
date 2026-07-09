import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/catalog_category_entity.dart';

abstract interface class CatalogCategoryRepository {
  /// No pagination in the API spec for this endpoint — returns a flat list.
  Future<Either<Failure, List<CatalogCategoryEntity>>> getCategories();

  Future<Either<Failure, CatalogCategoryEntity>> getCategoryById(int id);
}
