import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/catalog_category_entity.dart';
import '../../domain/repositories/catalog_category_repository.dart';
import '../datasources/catalog_category_remote_datasource.dart';
import '../models/catalog_category_model.dart';

class CatalogCategoryRepositoryImpl implements CatalogCategoryRepository {
  const CatalogCategoryRepositoryImpl(this._remote);

  final CatalogCategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CatalogCategoryEntity>>> getCategories() async {
    try {
      final models = await _remote.getCategories();
      return Right(models.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CatalogCategoryEntity>> getCategoryById(
    int id,
  ) async {
    try {
      final model = await _remote.getCategoryById(id);
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
