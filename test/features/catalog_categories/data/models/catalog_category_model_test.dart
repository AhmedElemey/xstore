import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/catalog_categories/data/models/catalog_category_model.dart';

void main() {
  group('CatalogCategoryModel.fromJson', () {
    test('falls back to name when nameEn is absent', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 1,
        'name': 'Other',
        'nameAr': 'أخرى',
      });

      expect(model.nameEn, 'Other');
      expect(model.nameAr, 'أخرى');
    });

    test('parses string ids and parentIds', () {
      final model = CatalogCategoryModel.fromJson({
        'id': '32',
        'nameEn': 'Parts',
        'nameAr': 'قطع غيار',
        'parentId': '7',
      });

      expect(model.id, 32);
      expect(model.parentId, 7);
    });

    test('treats a missing or non-list children field as empty', () {
      final missing = CatalogCategoryModel.fromJson({
        'id': 7,
        'nameEn': 'Automotive',
        'nameAr': 'السيارات',
      });
      expect(missing.children, isEmpty);

      final notAList = CatalogCategoryModel.fromJson({
        'id': 7,
        'nameEn': 'Automotive',
        'nameAr': 'السيارات',
        'children': 'oops',
      });
      expect(notAList.children, isEmpty);
    });

    test('skips non-map children instead of failing the parent', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 7,
        'nameEn': 'Automotive',
        'nameAr': 'السيارات',
        'children': [
          {
            'id': 32,
            'nameEn': 'Parts',
            'nameAr': 'قطع غيار',
            'parentId': 7,
          },
          'not-an-object',
          99,
        ],
      });

      expect(model.children, hasLength(1));
      expect(model.children.single.id, 32);
    });
  });

  group('CatalogCategoryModel.toEntity', () {
    test('maps bilingual names and nested children', () {
      const model = CatalogCategoryModel(
        id: 7,
        nameEn: 'Automotive',
        nameAr: 'السيارات',
        children: [
          CatalogCategoryModel(
            id: 32,
            nameEn: 'Parts',
            nameAr: 'قطع غيار',
            parentId: 7,
          ),
        ],
      );

      final entity = model.toEntity();

      expect(entity.id, 7);
      expect(entity.name.en, 'Automotive');
      expect(entity.name.ar, 'السيارات');
      expect(entity.children.single.id, 32);
      expect(entity.children.single.parentId, 7);
      expect(entity.children.single.name.en, 'Parts');
    });
  });
}
