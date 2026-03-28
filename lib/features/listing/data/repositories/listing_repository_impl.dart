import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';
import '../models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl(this._remote);

  final ListingRemoteDataSource _remote;

  @override
  Future<Either<Failure, ListingEntity>> createListing({
    required String title,
    required String description,
    required double price,
    required List<String> imagePaths,
  }) async {
    try {
      final model = await _remote.createListing(
        title: title,
        description: description,
        price: price,
        imagePaths: imagePaths,
      );
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getMyListings() async {
    try {
      final models = await _remote.fetchMyListings();
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
  Future<Either<Failure, ListingEntity>> updateListing({
    required String id,
    required String title,
    required String description,
    required double price,
    required ListingStatus status,
  }) async {
    try {
      final model = await _remote.updateListing(
        id: id,
        title: title,
        description: description,
        price: price,
        status: _statusToDto(status),
      );
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteListing(String id) async {
    try {
      await _remote.deleteListing(id);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  String _statusToDto(ListingStatus status) {
    switch (status) {
      case ListingStatus.pending:
        return 'pending';
      case ListingStatus.active:
        return 'active';
      case ListingStatus.draft:
        return 'draft';
    }
  }
}
