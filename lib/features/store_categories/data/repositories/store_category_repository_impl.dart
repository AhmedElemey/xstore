import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/store_category_entity.dart';
import '../../domain/repositories/store_category_repository.dart';
import '../datasources/store_category_remote_datasource.dart';
import '../models/store_category_model.dart';

class StoreCategoryRepositoryImpl implements StoreCategoryRepository {
  const StoreCategoryRepositoryImpl(this._remote);

  final StoreCategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<StoreCategoryEntity>>>
      getStoreCategories({
    required int page,
    required int pageSize,
  }) async {
    try {
      final result =
          await _remote.getStoreCategories(page: page, pageSize: pageSize);
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
  Future<Either<Failure, StoreCategoryEntity>> getStoreCategoryById(
    int id,
  ) async {
    try {
      final model = await _remote.getStoreCategoryById(id);
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
