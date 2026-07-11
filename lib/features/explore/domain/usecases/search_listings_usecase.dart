import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_result_entity.dart';
import '../repositories/explore_repository.dart';

class SearchListingsUseCase {
  const SearchListingsUseCase(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<SearchResultEntity>>> call({
    required String query,
    required int page,
    double? minPrice,
    double? maxPrice,
    String? condition,
  }) =>
      _repository.searchListings(
        query: query,
        page: page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        condition: condition,
      );
}
