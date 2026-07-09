import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/government_entity.dart';
import '../../domain/repositories/government_repository.dart';
import '../datasources/government_remote_datasource.dart';
import '../models/government_model.dart';

class GovernmentRepositoryImpl implements GovernmentRepository {
  const GovernmentRepositoryImpl(this._remote);

  final GovernmentRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<GovernmentEntity>>> getGovernments({
    required int page,
    required int pageSize,
  }) async {
    try {
      final result =
          await _remote.getGovernments(page: page, pageSize: pageSize);
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
  Future<Either<Failure, GovernmentEntity>> getGovernmentById(int id) async {
    try {
      final model = await _remote.getGovernmentById(id);
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
