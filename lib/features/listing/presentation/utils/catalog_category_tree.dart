import '../../../catalog_categories/domain/entities/catalog_category_entity.dart';

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
