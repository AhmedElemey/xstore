import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/features/catalog_categories/data/models/catalog_category_model.dart';
import 'package:xstore/features/catalog_categories/domain/entities/catalog_category_entity.dart';
import 'package:xstore/features/listing/presentation/utils/catalog_category_tree.dart';

void main() {
  group('CatalogCategoryModel.fromJson', () {
    test('keeps nested children as subcategories', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 7,
        'nameEn': 'Automotive',
        'nameAr': 'السيارات',
        'parentId': null,
        'children': [
          {
            'id': 32,
            'nameEn': 'Parts',
            'nameAr': 'قطع غيار',
            'parentId': 7,
            'children': <Map<String, dynamic>>[],
          },
          {
            'id': 33,
            'nameEn': 'Accessories',
            'nameAr': 'الإكسسوارات',
            'parentId': 7,
            'children': <Map<String, dynamic>>[],
          },
        ],
      });

      expect(model.id, 7);
      expect(model.parentId, isNull);
      expect(model.children, hasLength(2));
      expect(model.children.first.id, 32);
      expect(model.children.first.parentId, 7);
      expect(model.children.first.nameEn, 'Parts');

      final entity = model.toEntity();
      expect(entity.children, hasLength(2));
      expect(entity.children.map((c) => c.id), [32, 33]);
    });

    test('parses the live GET /api/categories row shape', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 7,
        'nameEn': 'Automotive',
        'nameAr': 'السيارات',
        'imageUrl': 'http://xstoreegy-001-site1.jtempurl.com/car',
        'isActive': true,
        'parentId': null,
        'children': [
          {
            'id': 32,
            'nameEn': 'Parts',
            'nameAr': 'قطع غيار',
            'imageUrl': null,
            'isActive': true,
            'parentId': 7,
            'children': <dynamic>[],
          },
        ],
      });
      expect(model.nameEn, 'Automotive');
      expect(model.children.single.nameEn, 'Parts');
      expect(subcategoriesOf([model.toEntity()], 7).single.name.en, 'Parts');
    });

    test('drops inactive children and accepts subCategories alias', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 1,
        'nameEn': 'Electronics',
        'nameAr': 'إلكترونيات',
        'isActive': true,
        'subCategories': [
          {
            'id': 11,
            'nameEn': 'Phones',
            'nameAr': 'هواتف',
            'isActive': true,
            'parentId': 1,
          },
          {
            'id': 12,
            'nameEn': 'Hidden',
            'nameAr': 'مخفي',
            'isActive': false,
            'parentId': 1,
          },
        ],
      });
      expect(model.children.map((c) => c.nameEn), ['Phones']);
    });

    test('treats parentId 0 as top-level', () {
      final model = CatalogCategoryModel.fromJson({
        'id': 1,
        'nameEn': 'Other',
        'nameAr': 'أخرى',
        'parentId': 0,
        'children': <Map<String, dynamic>>[],
      });
      expect(model.parentId, isNull);
    });
  });

  group('catalog category tree', () {
    const all = [
      CatalogCategoryEntity(
        id: 4,
        name: LocalizedText(en: 'Beauty', ar: 'الجمال'),
        children: [
          CatalogCategoryEntity(
            id: 23,
            name: LocalizedText(en: 'Skincare', ar: 'العناية بالبشرة'),
            parentId: 4,
          ),
          CatalogCategoryEntity(
            id: 24,
            name: LocalizedText(en: 'Makeup', ar: 'مكياج'),
            parentId: 4,
          ),
        ],
      ),
      CatalogCategoryEntity(
        id: 9,
        name: LocalizedText(en: 'Books', ar: 'كتب'),
        children: [
          CatalogCategoryEntity(
            id: 40,
            name: LocalizedText(en: 'Fiction', ar: 'خيال'),
            parentId: 9,
          ),
        ],
      ),
    ];

    test('top-level ignores nested children', () {
      expect(topLevelCategories(all).map((c) => c.id), [4, 9]);
    });

    test('subcategories come from the parent children array', () {
      expect(subcategoriesOf(all, 4).map((c) => c.id), [23, 24]);
      expect(subcategoriesOf(all, 9).map((c) => c.id), [40]);
      expect(subcategoriesOf(all, 99), isEmpty);
    });

    test('lookup finds nested children', () {
      expect(catalogCategoryById(all, 4)?.name.en, 'Beauty');
      expect(catalogCategoryById(all, 23)?.name.en, 'Skincare');
      expect(catalogCategoryById(all, 99), isNull);
    });
  });
}
