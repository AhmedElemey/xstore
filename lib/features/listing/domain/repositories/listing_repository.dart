import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';

abstract interface class ListingRepository {
  Future<Either<Failure, ListingEntity>> createListing({
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    List<String> imagePaths = const [],
  });

  Future<Either<Failure, List<ListingEntity>>> getMyListings();

  Future<Either<Failure, ListingEntity>> updateListing({
    required String id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    required List<String> imagePaths,
    required ListingStatus status,
  });

  Future<Either<Failure, Unit>> deleteListing(String id);

  Future<Either<Failure, ListingEntity>> resubmitListing({
    required String id,
    required double newPrice,
  });

  Future<Either<Failure, ListingEntity>> deactivateListing(String id);
}
