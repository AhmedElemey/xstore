import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() =>
      _repository.getCategories();
}
