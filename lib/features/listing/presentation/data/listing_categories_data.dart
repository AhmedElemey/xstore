import 'package:flutter/material.dart';

/// Static taxonomy for listing form (presentation layer).
abstract final class ListingCategoriesData {
  static const List<ListingCategoryOption> categories = [
    ListingCategoryOption(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.devices_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'phones', name: 'Phones & tablets'),
        ListingSubcategoryOption(id: 'laptops', name: 'Laptops & PCs'),
        ListingSubcategoryOption(id: 'audio', name: 'Audio'),
        ListingSubcategoryOption(id: 'accessories', name: 'Accessories'),
      ],
      attributeHints: ['RAM', 'Storage', 'Battery', 'Screen size'],
    ),
    ListingCategoryOption(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'mens', name: "Men's"),
        ListingSubcategoryOption(id: 'womens', name: "Women's"),
        ListingSubcategoryOption(id: 'kids', name: 'Kids'),
        ListingSubcategoryOption(id: 'shoes', name: 'Shoes'),
      ],
      attributeHints: ['Size', 'Color', 'Material', 'Fit'],
    ),
    ListingCategoryOption(
      id: 'home',
      name: 'Home & Garden',
      icon: Icons.home_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'furniture', name: 'Furniture'),
        ListingSubcategoryOption(id: 'decor', name: 'Decor'),
        ListingSubcategoryOption(id: 'kitchen', name: 'Kitchen'),
        ListingSubcategoryOption(id: 'garden', name: 'Garden'),
      ],
      attributeHints: ['Dimensions', 'Color', 'Material', 'Weight'],
    ),
    ListingCategoryOption(
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.spa_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'skincare', name: 'Skincare'),
        ListingSubcategoryOption(id: 'makeup', name: 'Makeup'),
        ListingSubcategoryOption(id: 'hair', name: 'Hair care'),
      ],
      attributeHints: ['Volume', 'Skin type', 'Ingredients'],
    ),
    ListingCategoryOption(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'fitness', name: 'Fitness'),
        ListingSubcategoryOption(id: 'outdoor', name: 'Outdoor'),
        ListingSubcategoryOption(id: 'team', name: 'Team sports'),
      ],
      attributeHints: ['Size', 'Weight', 'Material'],
    ),
    ListingCategoryOption(
      id: 'toys',
      name: 'Toys',
      icon: Icons.toys_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'games', name: 'Games'),
        ListingSubcategoryOption(id: 'dolls', name: 'Dolls & figures'),
        ListingSubcategoryOption(id: 'educational', name: 'Educational'),
      ],
      attributeHints: ['Age range', 'Material', 'Battery'],
    ),
    ListingCategoryOption(
      id: 'automotive',
      name: 'Automotive',
      icon: Icons.directions_car_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'parts', name: 'Parts'),
        ListingSubcategoryOption(id: 'accessories', name: 'Accessories'),
        ListingSubcategoryOption(id: 'care', name: 'Care products'),
      ],
      attributeHints: ['Compatibility', 'Year', 'Part number'],
    ),
    ListingCategoryOption(
      id: 'food',
      name: 'Food & Drinks',
      icon: Icons.restaurant_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'beverages', name: 'Beverages'),
        ListingSubcategoryOption(id: 'snacks', name: 'Snacks'),
        ListingSubcategoryOption(id: 'grocery', name: 'Grocery'),
      ],
      attributeHints: ['Weight', 'Expiry', 'Ingredients'],
    ),
    ListingCategoryOption(
      id: 'books',
      name: 'Books',
      icon: Icons.menu_book_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'fiction', name: 'Fiction'),
        ListingSubcategoryOption(id: 'nonfiction', name: 'Non-fiction'),
        ListingSubcategoryOption(id: 'textbooks', name: 'Textbooks'),
      ],
      attributeHints: ['Author', 'ISBN', 'Language'],
    ),
    ListingCategoryOption(
      id: 'other',
      name: 'Other',
      icon: Icons.category_outlined,
      subcategories: [
        ListingSubcategoryOption(id: 'misc', name: 'Miscellaneous'),
      ],
      attributeHints: ['Type', 'Condition notes'],
    ),
  ];

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

  static const List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Used',
    'For Parts',
  ];

  static ListingCategoryOption? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }
}

class ListingCategoryOption {
  const ListingCategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
    required this.attributeHints,
  });

  final String id;
  final String name;
  final IconData icon;
  final List<ListingSubcategoryOption> subcategories;
  final List<String> attributeHints;
}

class ListingSubcategoryOption {
  const ListingSubcategoryOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
