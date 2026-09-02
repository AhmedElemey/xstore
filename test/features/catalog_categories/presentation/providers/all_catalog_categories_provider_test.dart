import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/features/catalog_categories/domain/entities/catalog_category_entity.dart';
import 'package:xstore/features/catalog_categories/domain/repositories/catalog_category_repository.dart';
import 'package:xstore/features/catalog_categories/domain/usecases/get_categories_usecase.dart';
import 'package:xstore/features/catalog_categories/presentation/providers/catalog_category_dependencies.dart';

const _automotive = CatalogCategoryEntity(
  id: 7,
  name: LocalizedText(en: 'Automotive', ar: 'السيارات'),
  children: [
    CatalogCategoryEntity(
      id: 32,
      name: LocalizedText(en: 'Parts', ar: 'قطع غيار'),
      parentId: 7,
    ),
  ],
);

class _FakeRepo implements CatalogCategoryRepository {
  _FakeRepo(this._result);

  final Either<Failure, List<CatalogCategoryEntity>> _result;
  int calls = 0;

  @override
  Future<Either<Failure, List<CatalogCategoryEntity>>> getCategories() async {
    calls++;
    return _result;
  }
}

ProviderContainer _containerFor(_FakeRepo repo) {
  final container = ProviderContainer(
    overrides: [
      getCategoriesUseCaseProvider.overrideWithValue(
        GetCategoriesUseCase(repo),
      ),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose FutureProviders need a real listener held open across the
  // awaited fetch, or the provider can be disposed mid-flight and silently
  // rebuilt (see the 2026-08-29 "bare container.read doesn't keep an
  // autoDispose provider alive across an await" lesson).
  container.listen(allCatalogCategoriesProvider, (_, __) {});
  return container;
}

void main() {
  group('allCatalogCategoriesProvider', () {
    test('returns the fetched catalog on success', () async {
      final repo = _FakeRepo(const Right([_automotive]));
      final container = _containerFor(repo);

      final items = await container.read(allCatalogCategoriesProvider.future);

      expect(items.single.id, 7);
      expect(items.single.name.en, 'Automotive');
      expect(items.single.children.single.name.en, 'Parts');
    });

    test('throws the Failure when the usecase returns Left', () async {
      final repo = _FakeRepo(Left(Failure.network('offline')));
      final container = _containerFor(repo);

      await expectLater(
        container.read(allCatalogCategoriesProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('pins a successful fetch so a second listen does not refetch',
        () async {
      final repo = _FakeRepo(const Right([_automotive]));
      final container = ProviderContainer(
        overrides: [
          getCategoriesUseCaseProvider.overrideWithValue(
            GetCategoriesUseCase(repo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(allCatalogCategoriesProvider, (_, __) {});
      await container.read(allCatalogCategoriesProvider.future);
      expect(repo.calls, 1);

      sub.close();
      await Future<void>.delayed(Duration.zero);

      final sub2 = container.listen(allCatalogCategoriesProvider, (_, __) {});
      addTearDown(sub2.close);
      final items = await container.read(allCatalogCategoriesProvider.future);

      expect(repo.calls, 1);
      expect(items.single.id, 7);
    });

    test('does not pin a failed fetch so a second listen retries', () async {
      final repo = _FakeRepo(Left(Failure.server('boom')));
      final container = ProviderContainer(
        overrides: [
          getCategoriesUseCaseProvider.overrideWithValue(
            GetCategoriesUseCase(repo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(allCatalogCategoriesProvider, (_, __) {});
      await expectLater(
        container.read(allCatalogCategoriesProvider.future),
        throwsA(isA<ServerFailure>()),
      );
      expect(repo.calls, 1);

      sub.close();
      await Future<void>.delayed(Duration.zero);

      final sub2 = container.listen(allCatalogCategoriesProvider, (_, __) {});
      addTearDown(sub2.close);
      await expectLater(
        container.read(allCatalogCategoriesProvider.future),
        throwsA(isA<ServerFailure>()),
      );
      expect(repo.calls, 2);
    });
  });
}
