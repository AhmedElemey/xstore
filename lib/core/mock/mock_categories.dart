import '../../features/home/data/models/category_model.dart';
import 'mock_images.dart';

final mockCategoryModels = [
  CategoryModel(
    id: 'cat_electronics',
    name: 'Electronics',
    iconUrl: MockImages.category(1),
  ),
  CategoryModel(
    id: 'cat_fashion',
    name: 'Fashion',
    iconUrl: MockImages.category(2),
  ),
  CategoryModel(
    id: 'cat_home',
    name: 'Home',
    iconUrl: MockImages.category(3),
  ),
  CategoryModel(
    id: 'cat_beauty',
    name: 'Beauty',
    iconUrl: MockImages.category(4),
  ),
  CategoryModel(
    id: 'cat_sports',
    name: 'Sports',
    iconUrl: MockImages.category(5),
  ),
  CategoryModel(
    id: 'cat_toys',
    name: 'Toys',
    iconUrl: MockImages.category(6),
  ),
  CategoryModel(
    id: 'cat_automotive',
    name: 'Automotive',
    iconUrl: MockImages.category(7),
  ),
  CategoryModel(
    id: 'cat_books',
    name: 'Books',
    iconUrl: MockImages.category(8),
  ),
];

/// Subcategory labels for picker flows / docs (home [CategoryModel] has no subs).
final mockSubcategoriesByCategoryId = <String, List<String>>{
  'cat_electronics': [
    'Phones',
    'Laptops',
    'Tablets',
    'Accessories',
    'Audio',
    'Gaming',
  ],
  'cat_fashion': [
    "Men's",
    "Women's",
    'Kids',
    'Shoes',
    'Bags',
    'Jewelry',
  ],
  'cat_home': [
    'Furniture',
    'Kitchen',
    'Decor',
    'Garden',
    'Lighting',
    'Storage',
  ],
  'cat_beauty': [
    'Skincare',
    'Makeup',
    'Haircare',
    'Perfume',
    'Tools',
  ],
  'cat_sports': [
    'Fitness',
    'Football',
    'Running',
    'Cycling',
    'Swimming',
  ],
  'cat_toys': [
    'Action Figures',
    'Puzzles',
    'Educational',
    'Outdoor',
  ],
  'cat_automotive': [
    'Car Parts',
    'Accessories',
    'Tools',
    'Care Products',
  ],
  'cat_books': [
    'Fiction',
    'Science',
    'Business',
    'Self-Help',
    'Children',
  ],
};
