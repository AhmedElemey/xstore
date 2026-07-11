import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';
import '../models/search_result_model.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl(this._remote);

  final ExploreRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchListings({
    required String query,
    required int page,
    double? minPrice,
    double? maxPrice,
    String? condition,
  }) async {
    try {
      final models = await _remote.searchListings(
        query,
        page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        condition: condition,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestions(String query) async {
    try {
      final list = await _remote.getSuggestions(query);
      return Right(list);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
