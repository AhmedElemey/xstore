import '../../features/catalog_categories/data/models/catalog_category_model.dart';
import '../../features/cities/data/models/city_model.dart';
import '../../features/governments/data/models/government_model.dart';
import '../../features/store_categories/data/models/store_category_model.dart';

/// Fixtures keeping the app fully functional under `MockConfig.useMock`
/// (the default) with no backend running.
abstract final class MockReferenceData {
  static const cities = <CityModel>[
    CityModel(id: 1, nameEn: 'Cairo', nameAr: 'القاهرة'),
    CityModel(id: 2, nameEn: 'Alexandria', nameAr: 'الإسكندرية'),
    CityModel(id: 3, nameEn: 'Giza', nameAr: 'الجيزة'),
    CityModel(id: 4, nameEn: 'Port Said', nameAr: 'بورسعيد'),
    CityModel(id: 5, nameEn: 'Suez', nameAr: 'السويس'),
    CityModel(id: 6, nameEn: 'Luxor', nameAr: 'الأقصر'),
    CityModel(id: 7, nameEn: 'Aswan', nameAr: 'أسوان'),
    CityModel(id: 8, nameEn: 'Mansoura', nameAr: 'المنصورة'),
    CityModel(id: 9, nameEn: 'Tanta', nameAr: 'طنطا'),
    CityModel(id: 10, nameEn: 'Ismailia', nameAr: 'الإسماعيلية'),
  ];

  static const governments = <GovernmentModel>[
    GovernmentModel(id: 1, nameEn: 'Cairo', nameAr: 'القاهرة', cityId: 1),
    GovernmentModel(id: 2, nameEn: 'Alexandria', nameAr: 'الإسكندرية', cityId: 2),
    GovernmentModel(id: 3, nameEn: 'Giza', nameAr: 'الجيزة', cityId: 3),
    GovernmentModel(id: 4, nameEn: 'Qalyubia', nameAr: 'القليوبية', cityId: 1),
    GovernmentModel(id: 5, nameEn: 'Port Said', nameAr: 'بورسعيد', cityId: 4),
    GovernmentModel(id: 6, nameEn: 'Suez', nameAr: 'السويس', cityId: 5),
    GovernmentModel(id: 7, nameEn: 'Luxor', nameAr: 'الأقصر', cityId: 6),
    GovernmentModel(id: 8, nameEn: 'Aswan', nameAr: 'أسوان', cityId: 7),
    GovernmentModel(id: 9, nameEn: 'Dakahlia', nameAr: 'الدقهلية', cityId: 8),
    GovernmentModel(id: 10, nameEn: 'Gharbia', nameAr: 'الغربية', cityId: 9),
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
    CatalogCategoryModel(id: 1, nameEn: 'Electronics', nameAr: 'إلكترونيات'),
    CatalogCategoryModel(id: 2, nameEn: 'Fashion', nameAr: 'أزياء'),
    CatalogCategoryModel(id: 3, nameEn: 'Home', nameAr: 'المنزل'),
    CatalogCategoryModel(id: 4, nameEn: 'Beauty', nameAr: 'الجمال'),
    CatalogCategoryModel(id: 5, nameEn: 'Sports', nameAr: 'رياضة'),
    CatalogCategoryModel(id: 6, nameEn: 'Toys', nameAr: 'ألعاب'),
    CatalogCategoryModel(id: 7, nameEn: 'Automotive', nameAr: 'سيارات'),
    CatalogCategoryModel(id: 8, nameEn: 'Food', nameAr: 'طعام'),
    CatalogCategoryModel(id: 9, nameEn: 'Books', nameAr: 'كتب'),
  ];
}
