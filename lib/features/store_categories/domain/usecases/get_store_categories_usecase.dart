import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/store_category_entity.dart';
import '../repositories/store_category_repository.dart';

class GetStoreCategoriesUseCase {
  const GetStoreCategoriesUseCase(this._repository);

  final StoreCategoryRepository _repository;

  Future<Either<Failure, PaginatedResult<StoreCategoryEntity>>> call({
    required int page,
    required int pageSize,
  }) {
    return _repository.getStoreCategories(page: page, pageSize: pageSize);
  }
}
