import '../../../catalog_categories/domain/entities/catalog_category_entity.dart';

/// Top-level categories from `GET /api/categories` (rows with no parent).
List<CatalogCategoryEntity> topLevelCategories(
  List<CatalogCategoryEntity> all,
) =>
    all.where((c) => c.parentId == null).toList();

/// Subcategories of [categoryId]: that category's nested `children`.
List<CatalogCategoryEntity> subcategoriesOf(
  List<CatalogCategoryEntity> all,
  int categoryId,
) {
  for (final c in all) {
    if (c.id == categoryId) return c.children;
  }
  return const [];
}

/// Finds a category or nested child by id.
CatalogCategoryEntity? catalogCategoryById(
  List<CatalogCategoryEntity> all,
  int id,
) {
  for (final c in all) {
    if (c.id == id) return c;
    for (final child in c.children) {
      if (child.id == id) return child;
    }
  }
  return null;
}
