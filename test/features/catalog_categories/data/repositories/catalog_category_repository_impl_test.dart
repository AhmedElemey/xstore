import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/catalog_categories/data/datasources/catalog_category_remote_datasource.dart';
import 'package:xstore/features/catalog_categories/data/models/catalog_category_model.dart';
import 'package:xstore/features/catalog_categories/data/repositories/catalog_category_repository_impl.dart';

class _FakeRemote implements CatalogCategoryRemoteDataSource {
  _FakeRemote(this._get);

  final Future<List<CatalogCategoryModel>> Function() _get;

  @override
  Future<List<CatalogCategoryModel>> getCategories() => _get();
}

CatalogCategoryModel _model({
  int id = 7,
  String nameEn = 'Automotive',
  String nameAr = 'السيارات',
  List<CatalogCategoryModel> children = const [],
}) =>
    CatalogCategoryModel(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      children: children,
    );

void main() {
  group('getCategories', () {
    test('maps remote models to entities as Right', () async {
      final repo = CatalogCategoryRepositoryImpl(
        _FakeRemote(
          () async => [
            _model(
              children: [
                _model(id: 32, nameEn: 'Parts', nameAr: 'قطع غيار'),
              ],
            ),
            _model(id: 4, nameEn: 'Beauty', nameAr: 'الجمال'),
          ],
        ),
      );

      final result = await repo.getCategories();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (list) {
        expect(list, hasLength(2));
        expect(list.first.id, 7);
        expect(list.first.name.en, 'Automotive');
        expect(list.first.name.ar, 'السيارات');
        expect(list.first.children.single.name.en, 'Parts');
        expect(list.last.name.en, 'Beauty');
      });
    });

    test('maps a thrown NetworkException to Failure.network', () async {
      final repo = CatalogCategoryRepositoryImpl(
        _FakeRemote(() async => throw const NetworkException('offline')),
      );

      final result = await repo.getCategories();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<NetworkFailure>());
          expect(f.message, 'offline');
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps a thrown ServerException to Failure.server', () async {
      final repo = CatalogCategoryRepositoryImpl(
        _FakeRemote(() async => throw const ServerException('boom')),
      );

      final result = await repo.getCategories();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<ServerFailure>());
          expect(f.message, 'boom');
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps any other thrown exception to Failure.server', () async {
      final repo = CatalogCategoryRepositoryImpl(
        _FakeRemote(() async => throw const UnauthorizedException('nope')),
      );

      final result = await repo.getCategories();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
