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

  group('getHomeFeed', () {
    test('maps every aggregate section to entities', () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
          onFetchHomeAggregate: () async => (
            banners: const [
              BannerModel(id: 'b1', title: 'Sale', imageUrl: 'https://example.test/b1.jpg'),
            ],
            hotDeals: const [DealModel(id: 'd1', title: 'Deal', price: 90)],
            newArrivals: const [DealModel(id: 'n1', title: 'New', price: 50)],
            recommendedForYou: const [DealModel(id: 'r1', title: 'Rec', price: 60)],
          ),
        ),
      );

      final feed = await repo.getHomeFeed();

      expect(feed!.banners.single.id, 'b1');
      expect(feed.hotDeals.single.id, 'd1');
      expect(feed.newArrivals.single.id, 'n1');
      expect(feed.recommended.single.id, 'r1');
    });

    test('is null when the aggregate is unavailable or throws', () async {
      expect(
        await HomeRepositoryImpl(
          StubHomeRemoteDataSource(onFetchHomeAggregate: () async => null),
        ).getHomeFeed(),
        isNull,
      );
      expect(
        await HomeRepositoryImpl(
          StubHomeRemoteDataSource(
            onFetchHomeAggregate: () async => throw Exception('boom'),
          ),
        ).getHomeFeed(),
        isNull,
      );
    });
  });

  group('getNewArrivals', () {
    test('derives listings from hot deals',
        () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
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
    test('derives listings from hot deals',
        () async {
      final repo = HomeRepositoryImpl(
        StubHomeRemoteDataSource(
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
