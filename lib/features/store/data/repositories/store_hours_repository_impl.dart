import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/store_hours_entity.dart';
import '../../domain/repositories/store_hours_repository.dart';
import '../datasources/store_hours_datasource.dart';
import '../models/store_hours_model.dart';

class StoreHoursRepositoryImpl implements StoreHoursRepository {
  const StoreHoursRepositoryImpl(this._dataSource);

  final StoreHoursDataSource _dataSource;

  @override
  Future<Either<Failure, StoreHoursEntity>> getStoreHours(String vendorId) async {
    try {
      final result = await _dataSource.getStoreHours(vendorId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleStoreStatus(String vendorId, bool isOpen) async {
    try {
      final result = await _dataSource.toggleStoreStatus(vendorId, isOpen);
      return Right(result);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreHoursEntity>> updateStoreHours(StoreHoursEntity hours) async {
    try {
      final result = await _dataSource.updateStoreHours(StoreHoursModel.fromEntity(hours));
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

