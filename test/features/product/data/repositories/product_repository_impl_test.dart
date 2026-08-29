import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/network/paginated_result.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/product/data/repositories/product_repository_impl.dart';
import 'package:xstore/features/product/domain/entities/product_detail_entity.dart';
import 'package:xstore/features/product/domain/entities/review_entity.dart';
import 'package:xstore/features/product/domain/entities/review_write_params.dart';

import '../../../../helpers/stub_product_remote_datasource.dart';

ListingEntity _listing({String id = 'listing_1'}) => ListingEntity(
      id: id,
      title: 'Test Listing',
      description: 'A listing',
      price: 500,
      status: ListingStatus.active,
    );

ProductDetailEntity _detail({String id = 'listing_1'}) =>
    ProductDetailEntity(listing: _listing(id: id));

ReviewEntity _review({String id = 'r1'}) => ReviewEntity(
      id: id,
      userId: 'u1',
      userName: 'Jane',
      rating: 5,
      comment: 'Great',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('getProductDetail', () {
    test('passes through the remote detail as Right', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onFetchProductDetail: (id) async => _detail(id: id),
        ),
      );

      final result = await repo.getProductDetail('listing_1');

      result.fold(
        (_) => fail('expected Right'),
        (detail) => expect(detail.listing.id, 'listing_1'),
      );
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onFetchProductDetail: (_) async => throw Exception('boom'),
        ),
      );

      final result = await repo.getProductDetail('listing_1');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
    });
  });

  group('getSimilarProducts', () {
    test('passes the productId/category through and returns Right', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onFetchSimilarProducts: ({required productId, required category}) async {
            expect(productId, 'listing_1');
            expect(category, 'Electronics');
            return [_detail(id: 'listing_2')];
          },
        ),
      );

      final result = await repo.getSimilarProducts(
        productId: 'listing_1',
        category: 'Electronics',
      );

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.listing.id, 'listing_2'),
      );
    });
  });

  group('getProductReviews', () {
    test('passes paging through and returns Right', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onFetchProductReviews: ({required listingId, required page, required pageSize}) async {
            expect(listingId, 'listing_1');
            expect(page, 2);
            expect(pageSize, 10);
            return PaginatedResult(
              items: [_review()],
              page: page,
              pageSize: pageSize,
              totalCount: 1,
            );
          },
        ),
      );

      final result = await repo.getProductReviews(
        productId: 'listing_1',
        page: 2,
        pageSize: 10,
      );

      result.fold(
        (_) => fail('expected Right'),
        (page) => expect(page.items.single.id, 'r1'),
      );
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onFetchProductReviews: ({required listingId, required page, required pageSize}) async =>
              throw Exception('boom'),
        ),
      );

      final result = await repo.getProductReviews(
        productId: 'listing_1',
        page: 1,
        pageSize: 20,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('createReview', () {
    test('passes params through and returns the created review as Right',
        () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onCreateReview: ({required listingId, required params}) async {
            expect(listingId, 'listing_1');
            expect(params.rating, 5);
            return _review();
          },
        ),
      );

      final result = await repo.createReview(
        listingId: 'listing_1',
        params: const ReviewWriteParams(rating: 5, comment: 'Great'),
      );

      result.fold((_) => fail('expected Right'), (r) => expect(r.id, 'r1'));
    });
  });

  group('updateReview', () {
    test('passes params through and returns the updated review as Right',
        () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onUpdateReview: ({required listingId, required reviewId, required params}) async {
            expect(reviewId, 'r1');
            return _review().copyWith(comment: params.comment);
          },
        ),
      );

      final result = await repo.updateReview(
        listingId: 'listing_1',
        reviewId: 'r1',
        params: const ReviewWriteParams(rating: 4, comment: 'Updated'),
      );

      result.fold(
        (_) => fail('expected Right'),
        (r) => expect(r.comment, 'Updated'),
      );
    });
  });

  group('deleteReview', () {
    test('returns Right(unit) on success', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onDeleteReview: ({required listingId, required reviewId}) async {},
        ),
      );

      final result = await repo.deleteReview(listingId: 'listing_1', reviewId: 'r1');

      expect(result.isRight(), isTrue);
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = ProductRepositoryImpl(
        remote: StubProductRemoteDataSource(
          onDeleteReview: ({required listingId, required reviewId}) async =>
              throw Exception('boom'),
        ),
      );

      final result = await repo.deleteReview(listingId: 'listing_1', reviewId: 'r1');

      expect(result.isLeft(), isTrue);
    });
  });
}
