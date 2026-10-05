import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/home/data/datasources/home_remote_datasource.dart';
import 'package:xstore/features/home/data/models/banner_model.dart';
import 'package:xstore/features/home/data/models/category_model.dart';
import 'package:xstore/features/home/data/models/deal_model.dart';
import 'package:xstore/features/home/data/repositories/home_repository_impl.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

import '../../../../helpers/stub_home_remote_datasource.dart';

void main() {
  group('getBanners', () {
    test('maps the model list to entities as Right', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchBanners: () async => const [
            BannerModel(id: 'b1', title: 'Sale', imageUrl: 'https://example.test/b1.jpg'),
          ],
        ),
      );

      final result = await repo.getBanners();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'b1'),
      );
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchBanners: () async => throw Exception('boom'),
        ),
      );

      final result = await repo.getBanners();

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
    });
  });

  group('getCategories', () {
    test('maps the model list to entities as Right', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchCategories: () async => const [
            CategoryModel(id: 'c1', name: 'Electronics'),
          ],
        ),
      );

      final result = await repo.getCategories();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.name, 'Electronics'),
      );
    });
  });

  group('getHomeFeed', () {
    HomeAggregate aggregate({
      List<DealModel> hotDeals = const [],
      List<DealModel> newArrivals = const [],
      List<DealModel> recommendedForYou = const [],
    }) =>
        (
          banners: <BannerModel>[],
          hotDeals: hotDeals,
          newArrivals: newArrivals,
          recommendedForYou: recommendedForYou,
        );

    test('fills every section from one aggregate fetch, no fallback',
        () async {
      var aggregateCalls = 0;
      var hotDealsFallbackCalled = false;
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async {
            aggregateCalls++;
            return aggregate(
              hotDeals: const [
                DealModel(id: 'd1', title: 'Deal', price: 90, discountPercent: 10),
              ],
              newArrivals: const [DealModel(id: 'n1', title: 'New', price: 50)],
              recommendedForYou: const [
                DealModel(id: 'r1', title: 'Rec', price: 60),
              ],
            );
          },
          onFetchHotDeals: () async {
            hotDealsFallbackCalled = true;
            return const <DealModel>[];
          },
        ),
      );

      final result = await repo.getHomeFeed();

      result.fold((_) => fail('expected Right'), (feed) {
        expect(feed.hotDeals.single.id, 'd1');
        expect(feed.newArrivals.single.id, 'n1');
        expect(feed.recommended.single.id, 'r1');
      });
      expect(aggregateCalls, 1);
      expect(hotDealsFallbackCalled, isFalse);
    });

    test('maps a sold-out deal to ListingStatus.sold', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => aggregate(
            hotDeals: const [DealModel(id: 'd1', title: 'Deal', price: 90)],
            newArrivals: const [
              DealModel(id: 'n1', title: 'Gone', price: 50, isSoldOut: true),
              DealModel(id: 'n2', title: 'Here', price: 50),
            ],
          ),
        ),
      );

      final result = await repo.getHomeFeed();

      result.fold(
        (_) => fail('expected Right'),
        (feed) => expect(
          feed.newArrivals.map((l) => l.status),
          [ListingStatus.sold, ListingStatus.active],
        ),
      );
    });

    test('derives hot deals from /api/listings when the aggregate has none, '
        'keeping the aggregate\'s other sections', () async {
      var fallbackCalls = 0;
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => aggregate(
            newArrivals: const [DealModel(id: 'n1', title: 'New', price: 50)],
            recommendedForYou: const [
              DealModel(id: 'r1', title: 'Rec', price: 60),
            ],
          ),
          onFetchHotDeals: () async {
            fallbackCalls++;
            return const [DealModel(id: 'hd1', title: 'Deal', price: 70)];
          },
        ),
      );

      final result = await repo.getHomeFeed();

      result.fold((_) => fail('expected Right'), (feed) {
        expect(feed.hotDeals.single.id, 'hd1');
        expect(feed.newArrivals.single.id, 'n1');
        expect(feed.recommended.single.id, 'r1');
      });
      expect(fallbackCalls, 1);
    });

    test('derives new arrivals and recommended from hot deals when the '
        'aggregate is unavailable, fetching the fallback once', () async {
      var fallbackCalls = 0;
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => null,
          onFetchHotDeals: () async {
            fallbackCalls++;
            return const [
              DealModel(id: 'hd1', title: 'Deal', price: 70),
              DealModel(id: 'hd2', title: 'Deal', price: 40),
            ];
          },
        ),
      );

      final result = await repo.getHomeFeed();

      result.fold((_) => fail('expected Right'), (feed) {
        expect(feed.hotDeals.map((d) => d.id), ['hd1', 'hd2']);
        // Newest first: the fallback reverses the id order.
        expect(feed.newArrivals.map((l) => l.id), ['hd2', 'hd1']);
        expect(feed.recommended.map((l) => l.id), ['hd1', 'hd2']);
      });
      expect(fallbackCalls, 1);
    });

    test('maps a failing hot-deals fallback to Failure.server', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => null,
          onFetchHotDeals: () async => throw Exception('boom'),
        ),
      );

      final result = await repo.getHomeFeed();

      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
