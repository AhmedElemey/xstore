// Explore silently swallowed search/loadMore failures into an empty result
// list with no error surfaced (flutter-review skill, 2026-08-07 "Mock-mode
// coverage is per-datasource" lesson). Verifies the fix: a real error from
// the repository now lands in ExploreState.error, is cleared on the next
// successful call, and a failed loadMore doesn't wipe already-loaded results.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/explore/domain/entities/search_result_entity.dart';
import 'package:xstore/features/explore/domain/repositories/explore_repository.dart';
import 'package:xstore/features/explore/presentation/explore_dependencies.dart';
import 'package:xstore/features/explore/presentation/explore_provider.dart';

SearchResultEntity _result(String id) => SearchResultEntity(
      id: id,
      name: 'Item $id',
      price: 100,
      condition: 'New',
      category: 'electronics',
      rating: 4.5,
      reviewCount: 10,
      sellerName: 'Seller',
      isSellerVerified: true,
      location: 'Cairo',
      hasShipping: true,
    );

class _StubExploreRepository implements ExploreRepository {
  Either<Failure, List<SearchResultEntity>> Function(int page)? searchResult;

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchListings({
    required String query,
    required int page,
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? categoryId,
  }) async =>
      searchResult?.call(page) ?? const Right(<SearchResultEntity>[]);

  @override
  Future<Either<Failure, List<String>>> getSuggestions(String query) async =>
      const Right(<String>[]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StubExploreRepository repo;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = _StubExploreRepository();
    container = ProviderContainer(
      overrides: [exploreRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    // Let AnalyticsService's async init finish before the container can be
    // disposed — otherwise it resumes on an already-disposed container and
    // throws into an unrelated test (see test/checkout_order_flow_test.dart
    // for the same fix with a fuller explanation).
    await container.read(analyticsServiceProvider).ready;
  });

  test('a search failure surfaces a distinct error instead of a silent empty list', () async {
    repo.searchResult = (_) => const Left(Failure.server('boom'));

    await container.read(exploreProvider.notifier).search('phone');

    final state = container.read(exploreProvider);
    expect(state.results, isEmpty);
    expect(state.error, isNotNull);
  });

  test('a successful search clears a previous error', () async {
    repo.searchResult = (_) => const Left(Failure.server('boom'));
    await container.read(exploreProvider.notifier).search('phone');
    expect(container.read(exploreProvider).error, isNotNull);

    repo.searchResult = (_) => Right([_result('1')]);
    await container.read(exploreProvider.notifier).search('phone');

    final state = container.read(exploreProvider);
    expect(state.error, isNull);
    expect(state.results, hasLength(1));
  });

  test('a failed loadMore keeps existing results and surfaces the error', () async {
    // A full page (20) on page 1 sets hasMore=true so loadMore() actually
    // calls the repository instead of short-circuiting.
    final firstPage = List.generate(20, (i) => _result('$i'));
    repo.searchResult =
        (page) => page == 1 ? Right(firstPage) : const Left(Failure.server('boom'));
    await container.read(exploreProvider.notifier).search('phone');
    expect(container.read(exploreProvider).results, hasLength(20));

    await container.read(exploreProvider.notifier).loadMore();

    final state = container.read(exploreProvider);
    expect(state.results, hasLength(20), reason: 'existing results must not be wiped');
    expect(state.isLoadingMore, isFalse);
    expect(state.error, isNotNull);
  });
}
