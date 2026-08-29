import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/store_categories/data/models/store_category_model.dart';
import 'package:xstore/features/store_categories/data/repositories/store_category_repository_impl.dart';

import '../../../../helpers/stub_store_category_remote_datasource.dart';

StoreCategoryModel _model({
  int id = 1,
  String nameEn = 'Electronics',
  String nameAr = 'إلكترونيات',
}) =>
    StoreCategoryModel(id: id, nameEn: nameEn, nameAr: nameAr);

void main() {
  group('getStoreCategories', () {
    test(
      'maps remote models to entities and preserves page/pageSize/totalCount',
      () async {
        final repo = StoreCategoryRepositoryImpl(
          StubStoreCategoryRemoteDataSource(
            onGetStoreCategories: ({required page, required pageSize}) async {
              expect(page, 1);
              expect(pageSize, 20);
              return (
                items: [
                  _model(),
                  _model(id: 2, nameEn: 'Fashion', nameAr: 'أزياء'),
                ],
                totalCount: 12,
              );
            },
          ),
        );

        final result = await repo.getStoreCategories(page: 1, pageSize: 20);

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (page) {
          expect(page.page, 1);
          expect(page.pageSize, 20);
          expect(page.totalCount, 12);
          expect(page.items, hasLength(2));
          expect(page.items.first.id, 1);
          expect(page.items.first.name.en, 'Electronics');
          expect(page.items.first.name.ar, 'إلكترونيات');
          expect(page.items.last.name.en, 'Fashion');
        });
      },
    );

    test('maps a thrown NetworkException to Failure.network', () async {
      final repo = StoreCategoryRepositoryImpl(
        StubStoreCategoryRemoteDataSource(
          onGetStoreCategories: ({required page, required pageSize}) async =>
              throw const NetworkException('offline'),
        ),
      );

      final result = await repo.getStoreCategories(page: 1, pageSize: 20);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps a thrown ServerException to Failure.server', () async {
      final repo = StoreCategoryRepositoryImpl(
        StubStoreCategoryRemoteDataSource(
          onGetStoreCategories: ({required page, required pageSize}) async =>
              throw const ServerException('boom'),
        ),
      );

      final result = await repo.getStoreCategories(page: 1, pageSize: 20);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
