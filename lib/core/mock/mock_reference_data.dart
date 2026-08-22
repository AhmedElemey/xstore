import '../../features/catalog_categories/data/models/catalog_category_model.dart';
import '../../features/cities/data/models/city_model.dart';
import '../../features/governments/data/models/government_model.dart';
import '../../features/store_categories/data/models/store_category_model.dart';

/// Fixtures keeping the app fully functional under `MockConfig.useMock`
/// with no backend running.
///
/// Hierarchy matches live API: governorates are parents; cities link upward
/// via [CityModel.governorateId].
abstract final class MockReferenceData {
  static const governments = <GovernmentModel>[
    GovernmentModel(id: 1, nameEn: 'Cairo', nameAr: 'القاهرة'),
    GovernmentModel(id: 2, nameEn: 'Alexandria', nameAr: 'الإسكندرية'),
    GovernmentModel(id: 3, nameEn: 'Giza', nameAr: 'الجيزة'),
    GovernmentModel(id: 4, nameEn: 'Qalyubia', nameAr: 'القليوبية'),
    GovernmentModel(id: 5, nameEn: 'Port Said', nameAr: 'بورسعيد'),
    GovernmentModel(id: 6, nameEn: 'Suez', nameAr: 'السويس'),
    GovernmentModel(id: 7, nameEn: 'Luxor', nameAr: 'الأقصر'),
    GovernmentModel(id: 8, nameEn: 'Aswan', nameAr: 'أسوان'),
    GovernmentModel(id: 9, nameEn: 'Dakahlia', nameAr: 'الدقهلية'),
    GovernmentModel(id: 10, nameEn: 'Gharbia', nameAr: 'الغربية'),
  ];

  static const cities = <CityModel>[
    CityModel(id: 1, nameEn: 'Cairo', nameAr: 'القاهرة', governorateId: 1),
    CityModel(
        id: 2, nameEn: 'Alexandria', nameAr: 'الإسكندرية', governorateId: 2),
    CityModel(id: 3, nameEn: 'Giza', nameAr: 'الجيزة', governorateId: 3),
    CityModel(id: 4, nameEn: 'Port Said', nameAr: 'بورسعيد', governorateId: 5),
    CityModel(id: 5, nameEn: 'Suez', nameAr: 'السويس', governorateId: 6),
    CityModel(id: 6, nameEn: 'Luxor', nameAr: 'الأقصر', governorateId: 7),
    CityModel(id: 7, nameEn: 'Aswan', nameAr: 'أسوان', governorateId: 8),
    CityModel(id: 8, nameEn: 'Mansoura', nameAr: 'المنصورة', governorateId: 9),
    CityModel(id: 9, nameEn: 'Tanta', nameAr: 'طنطا', governorateId: 10),
    CityModel(
        id: 10, nameEn: 'Ismailia', nameAr: 'الإسماعيلية', governorateId: 5),
  ];

  static const storeCategories = <StoreCategoryModel>[
    StoreCategoryModel(id: 1, nameEn: 'Electronics', nameAr: 'إلكترونيات'),
    StoreCategoryModel(id: 2, nameEn: 'Fashion', nameAr: 'أزياء'),
    StoreCategoryModel(id: 3, nameEn: 'Home', nameAr: 'المنزل'),
    StoreCategoryModel(id: 4, nameEn: 'Beauty', nameAr: 'الجمال'),
    StoreCategoryModel(id: 5, nameEn: 'Sports', nameAr: 'رياضة'),
    StoreCategoryModel(id: 6, nameEn: 'Books', nameAr: 'كتب'),
    StoreCategoryModel(id: 7, nameEn: 'Food', nameAr: 'طعام'),
    StoreCategoryModel(id: 8, nameEn: 'Automotive', nameAr: 'سيارات'),
    StoreCategoryModel(id: 9, nameEn: 'Mixed/Other', nameAr: 'متنوع/أخرى'),
  ];

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
