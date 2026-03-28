import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(UserEntity sessionUser);

  Future<Either<Failure, ProfileEntity>> getVendorStoreProfile(String sellerId);

  Future<Either<Failure, UserEntity>> updateProfile(UserEntity updated);

  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  });

  Future<Either<Failure, Unit>> deleteAccount();

  Future<Either<Failure, List<ListingEntity>>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  });
}
