import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/home/data/models/banner_model.dart';
import 'package:xstore/features/home/data/models/category_model.dart';
import 'package:xstore/features/home/data/models/deal_model.dart';
import 'package:xstore/features/home/data/repositories/home_repository_impl.dart';

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

  group('getHotDeals', () {
    test('maps the model list to entities as Right', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHotDeals: () async => const [
            DealModel(id: 'd1', title: 'Deal', price: 90, discountPercent: 10),
          ],
        ),
      );

      final result = await repo.getHotDeals();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'd1'),
      );
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

  group('getNewArrivals', () {
    test('builds listings from the aggregate\'s newArrivals when present',
        () async {
      var hotDealsFallbackCalled = false;
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => (
            banners: <BannerModel>[],
            hotDeals: <DealModel>[],
            newArrivals: const [DealModel(id: 'n1', title: 'New', price: 50)],
            recommendedForYou: <DealModel>[],
          ),
          // Should not be reached: the aggregate already has newArrivals.
          onFetchHotDeals: () async {
            hotDealsFallbackCalled = true;
            return const <DealModel>[];
          },
        ),
      );

      final result = await repo.getNewArrivals();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'n1'),
      );
      expect(hotDealsFallbackCalled, isFalse);
    });

    test('falls back to hot-deals-derived listings when the aggregate has none',
        () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => null,
          onFetchHotDeals: () async => const [
            DealModel(id: 'hd1', title: 'Deal', price: 70),
          ],
        ),
      );

      final result = await repo.getNewArrivals();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'hd1'),
      );
    });
  });

  group('getRecommended', () {
    test('builds listings from the aggregate\'s recommendedForYou when present',
        () async {
      var hotDealsFallbackCalled = false;
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => (
            banners: <BannerModel>[],
            hotDeals: <DealModel>[],
            newArrivals: <DealModel>[],
            recommendedForYou: const [DealModel(id: 'r1', title: 'Rec', price: 60)],
          ),
          onFetchHotDeals: () async {
            hotDealsFallbackCalled = true;
            return const <DealModel>[];
          },
        ),
      );

      final result = await repo.getRecommended();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'r1'),
      );
      expect(hotDealsFallbackCalled, isFalse);
    });

    test('falls back to hot-deals-derived listings when the aggregate has none',
        () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => null,
          onFetchHotDeals: () async => const [
            DealModel(id: 'hd2', title: 'Deal', price: 40),
          ],
        ),
      );

      final result = await repo.getRecommended();

      result.fold(
        (_) => fail('expected Right'),
        (list) => expect(list.single.id, 'hd2'),
      );
    });
  });
}
