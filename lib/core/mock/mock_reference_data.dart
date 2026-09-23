import '../../features/catalog_categories/data/models/catalog_category_model.dart';

/// Fixtures keeping the app fully functional under `MockConfig.useMock`
/// with no backend running.
abstract final class MockReferenceData {
  static const catalogCategories = <CatalogCategoryModel>[
    CatalogCategoryModel(
      id: 1,
      nameEn: 'Electronics',
      nameAr: 'إلكترونيات',
      children: [
        CatalogCategoryModel(id: 11, nameEn: 'Phones', nameAr: 'هواتف', parentId: 1),
        CatalogCategoryModel(id: 12, nameEn: 'Laptops', nameAr: 'لابتوب', parentId: 1),
      ],
    ),
    CatalogCategoryModel(
      id: 2,
      nameEn: 'Fashion',
      nameAr: 'أزياء',
      children: [
        CatalogCategoryModel(id: 21, nameEn: "Men's", nameAr: 'رجالي', parentId: 2),
        CatalogCategoryModel(id: 22, nameEn: "Women's", nameAr: 'حريمي', parentId: 2),
      ],
    ),
    CatalogCategoryModel(
      id: 3,
      nameEn: 'Home',
      nameAr: 'المنزل',
      children: [
        CatalogCategoryModel(id: 31, nameEn: 'Furniture', nameAr: 'أثاث', parentId: 3),
      ],
    ),
    CatalogCategoryModel(
      id: 4,
      nameEn: 'Beauty',
      nameAr: 'الجمال',
      children: [
        CatalogCategoryModel(id: 41, nameEn: 'Skincare', nameAr: 'العناية بالبشرة', parentId: 4),
      ],
    ),
    CatalogCategoryModel(
      id: 5,
      nameEn: 'Sports',
      nameAr: 'رياضة',
      children: [
        CatalogCategoryModel(id: 51, nameEn: 'Fitness', nameAr: 'لياقة', parentId: 5),
      ],
    ),
    CatalogCategoryModel(
      id: 6,
      nameEn: 'Toys',
      nameAr: 'ألعاب',
      children: [
        CatalogCategoryModel(id: 61, nameEn: 'Games', nameAr: 'ألعاب', parentId: 6),
      ],
    ),
    CatalogCategoryModel(
      id: 7,
      nameEn: 'Automotive',
      nameAr: 'سيارات',
      children: [
        CatalogCategoryModel(id: 71, nameEn: 'Parts', nameAr: 'قطع غيار', parentId: 7),
      ],
    ),
    CatalogCategoryModel(
      id: 8,
      nameEn: 'Food',
      nameAr: 'طعام',
      children: [
        CatalogCategoryModel(id: 81, nameEn: 'Grocery', nameAr: 'بقالة', parentId: 8),
      ],
    ),
    CatalogCategoryModel(
      id: 9,
      nameEn: 'Books',
      nameAr: 'كتب',
      children: [
        CatalogCategoryModel(id: 91, nameEn: 'Fiction', nameAr: 'خيال', parentId: 9),
      ],
    ),
  ];
}
