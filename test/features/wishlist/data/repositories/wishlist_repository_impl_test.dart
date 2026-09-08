import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:xstore/features/wishlist/domain/entities/wishlist_item_entity.dart';

import '../../../../helpers/stub_cart_repository.dart';
import '../../../../helpers/stub_wishlist_remote_datasource.dart';

CartEntity _emptyCart(String consumerId) =>
    CartEntity(id: 'cart_stub', consumerId: consumerId, items: const []);

WishlistItemEntity _item({
  String id = 'wish_1',
  String listingId = 'listing_1',
}) {
  final now = DateTime(2026, 8, 1);
  return WishlistItemEntity(
    id: id,
    listingId: listingId,
    listingName: 'Leather Jacket',
    listingImages: const ['https://example.test/a.jpg'],
    vendorId: 'vendor_1',
    vendorName: 'Ahmed',
    vendorStoreName: 'Ahmed Store',
    price: 15000,
    category: 'Fashion',
    condition: 'New',
    addedAt: now,
    lastPriceCheckAt: now,
  );
}

void main() {
  group('getWishlist', () {
    test('passes through the remote list as Right', () async {
      final items = [_item(), _item(id: 'wish_2', listingId: 'listing_2')];
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(onGetWishlist: (_) async => items),
        StubCartRepository(),
      );

      final result = await repo.getWishlist('consumer_1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (list) {
        expect(list, hasLength(2));
        expect(list.first.listingId, 'listing_1');
        expect(list.last.listingId, 'listing_2');
      });
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(
          onGetWishlist: (_) async => throw const NetworkException('offline'),
        ),
        StubCartRepository(),
      );

      final result = await repo.getWishlist('consumer_1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('addToWishlist', () {
    test(
      'passes the consumer/listing ids through and returns the added item',
      () async {
        final added = _item(listingId: 'listing_9');
        final repo = WishlistRepositoryImpl(
          StubWishlistRemoteDataSource(
            onAddToWishlist: ({required consumerId, required listingId}) async {
              expect(consumerId, 'consumer_1');
              expect(listingId, 'listing_9');
              return added;
            },
          ),
          StubCartRepository(),
        );

        final result = await repo.addToWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('expected Right'),
          (item) => expect(item.listingId, 'listing_9'),
        );
      },
    );

    test('maps a thrown exception to Failure.server', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(
          onAddToWishlist: ({required consumerId, required listingId}) async =>
              throw const ServerException('boom'),
        ),
        StubCartRepository(),
      );

      final result = await repo.addToWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('removeFromWishlist', () {
    test(
      'passes the consumer/listing ids through and returns Right(unit)',
      () async {
        final repo = WishlistRepositoryImpl(
          StubWishlistRemoteDataSource(
            onRemoveFromWishlist:
                ({
                  required consumerId,
                  required listingId,
                  wishlistItemId,
                }) async {
                  expect(consumerId, 'consumer_1');
                  expect(listingId, 'listing_9');
                },
          ),
          StubCartRepository(),
        );

        final result = await repo.removeFromWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (u) => expect(u, unit));
      },
    );

    test('maps a thrown exception to Failure.server', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(
          onRemoveFromWishlist:
              ({
                required consumerId,
                required listingId,
                wishlistItemId,
              }) async => throw const UnauthorizedException('nope'),
        ),
        StubCartRepository(),
      );

      final result = await repo.removeFromWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('clearWishlist', () {
    test('returns Right(unit) on success', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(onClearWishlist: (_) async {}),
        StubCartRepository(),
      );

      final result = await repo.clearWishlist('consumer_1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (u) => expect(u, unit));
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(
          onClearWishlist: (_) async => throw const ServerException('boom'),
        ),
        StubCartRepository(),
      );

      final result = await repo.clearWishlist('consumer_1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('moveListingToCart', () {
    test(
      'delegates to CartRepository.addFromListing and discards the cart',
      () async {
        String? capturedConsumerId;
        String? capturedListingId;
        int? capturedQuantity;
        final repo = WishlistRepositoryImpl(
          StubWishlistRemoteDataSource(),
          StubCartRepository(
            addFromListingResult:
                ({required consumerId, required listingId, required quantity}) {
                  capturedConsumerId = consumerId;
                  capturedListingId = listingId;
                  capturedQuantity = quantity;
                  return Right(_emptyCart(consumerId));
                },
          ),
        );

        final result = await repo.moveListingToCart(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
          quantity: 2,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (u) => expect(u, unit));
        expect(capturedConsumerId, 'consumer_1');
        expect(capturedListingId, 'listing_9');
        expect(capturedQuantity, 2);
      },
    );

    test('defaults quantity to 1 when not specified', () async {
      int? capturedQuantity;
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(),
        StubCartRepository(
          addFromListingResult:
              ({required consumerId, required listingId, required quantity}) {
                capturedQuantity = quantity;
                return Right(_emptyCart(consumerId));
              },
        ),
      );

      await repo.moveListingToCart(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(capturedQuantity, 1);
    });

    test('propagates the CartRepository failure unchanged', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(),
        StubCartRepository(
          addFromListingResult:
              ({required consumerId, required listingId, required quantity}) =>
                  Left(Failure.validation('out of stock')),
        ),
      );

      final result = await repo.moveListingToCart(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('stubFromListingId', () {
    test(
      'returns the remote-built preview unwrapped (not an Either)',
      () async {
        final preview = _item(listingId: 'listing_1');
        final repo = WishlistRepositoryImpl(
          StubWishlistRemoteDataSource(
            onBuildFromListingId: (listingId, {wishId}) async {
              expect(listingId, 'listing_1');
              expect(wishId, isNull);
              return preview;
            },
          ),
          StubCartRepository(),
        );

        final result = await repo.stubFromListingId('listing_1');

        expect(result, preview);
      },
    );

    test('propagates a thrown exception unwrapped', () async {
      final repo = WishlistRepositoryImpl(
        StubWishlistRemoteDataSource(
          onBuildFromListingId: (listingId, {wishId}) async =>
              throw const ServerException('not found'),
        ),
        StubCartRepository(),
      );

      expect(
        () => repo.stubFromListingId('listing_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
