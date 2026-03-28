import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/deal_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/deal_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final models = await _remote.fetchBanners();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DealEntity>>> getHotDeals() async {
    try {
      final models = await _remote.fetchHotDeals();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _remote.fetchCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
