import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/store_category_entity.dart';

abstract interface class StoreCategoryRepository {
  Future<Either<Failure, PaginatedResult<StoreCategoryEntity>>>
      getStoreCategories({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, StoreCategoryEntity>> getStoreCategoryById(int id);
}
