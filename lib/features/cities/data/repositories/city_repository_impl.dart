import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/city_repository.dart';
import '../datasources/city_remote_datasource.dart';
import '../models/city_model.dart';

class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl(this._remote);

  final CityRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<CityEntity>>> getCities({
    required int page,
    required int pageSize,
  }) async {
    try {
      final result = await _remote.getCities(page: page, pageSize: pageSize);
      return Right(
        PaginatedResult(
          items: result.items.map((e) => e.toEntity()).toList(),
          page: page,
          pageSize: pageSize,
          totalCount: result.totalCount,
        ),
      );
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> getCityById(int id) async {
    try {
      final model = await _remote.getCityById(id);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
