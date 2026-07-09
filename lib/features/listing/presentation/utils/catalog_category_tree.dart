import '../../../catalog_categories/domain/entities/catalog_category_entity.dart';

/// Top-level categories: rows with no parent.
List<CatalogCategoryEntity> topLevelCategories(
  List<CatalogCategoryEntity> all,
) =>
    all.where((c) => c.parentId == null).toList();

/// Subcategories of [categoryId]: rows whose parentId points at it.
List<CatalogCategoryEntity> subcategoriesOf(
  List<CatalogCategoryEntity> all,
  int categoryId,
) =>
    all.where((c) => c.parentId == categoryId).toList();
