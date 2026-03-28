import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';

abstract interface class ListingRepository {
  Future<Either<Failure, ListingEntity>> createListing({
    required String title,
    required String description,
    required double price,
    required List<String> imagePaths,
  });

  Future<Either<Failure, List<ListingEntity>>> getMyListings();

  Future<Either<Failure, ListingEntity>> updateListing({
    required String id,
    required String title,
    required String description,
    required double price,
    required ListingStatus status,
  });

  Future<Either<Failure, Unit>> deleteListing(String id);
}
