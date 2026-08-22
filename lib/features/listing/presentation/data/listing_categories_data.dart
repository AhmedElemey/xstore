/// Static listing-form helpers that are **not** the product category tree.
/// Categories come from `GET /api/categories` (`allCatalogCategoriesProvider`).
abstract final class ListingCategoriesData {
  static const List<String> brandSuggestions = [
    'Apple',
    'Samsung',
    'Sony',
    'Nike',
    'Adidas',
    'IKEA',
    'Dell',
    'HP',
    'LG',
    'Bosch',
    'Canon',
    'Generic',
  ];

  /// Canonical condition display tokens — must stay 1:1 with the backend
  /// `ListingCondition` enum (New=1, LikeNew=2, Good=3, UsedForParts=4);
  /// see `listingConditionLabel` in listing_model.dart.
  static const List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Used / For Parts',
  ];
}
