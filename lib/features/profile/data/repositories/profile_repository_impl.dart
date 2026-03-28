import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(UserEntity sessionUser) async {
    try {
      final dto = await _remote.getProfile(sessionUser);
      return Right(dto.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> getVendorStoreProfile(String sellerId) async {
    try {
      final dto = await _remote.getVendorStoreProfile(sellerId);
      return Right(dto.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity updated) async {
    try {
      final model = await _remote.updateProfile(updated);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final url = await _remote.updateAvatar(
        userId: userId,
        filePath: filePath,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  }) async {
    try {
      final list = await _remote.fetchVendorStoreListings(
        sellerId: sellerId,
        categoryLabel: categoryLabel,
        page: page,
        pageSize: pageSize,
      );
      return Right(list);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
