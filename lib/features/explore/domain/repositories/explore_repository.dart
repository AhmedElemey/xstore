import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_result_entity.dart';

abstract interface class ExploreRepository {
  Future<Either<Failure, List<SearchResultEntity>>> searchListings({
    required String query,
    required int page,
    double? minPrice,
    double? maxPrice,
    String? condition,
  });

  Future<Either<Failure, List<String>>> getSuggestions(String query);
}
