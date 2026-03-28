import '../../features/home/data/models/banner_model.dart';
import 'mock_images.dart';

/// Hero carousel items (DTOs for [HomeRemoteDataSource]).
final mockBannerModels = [
  BannerModel(
    id: 'banner_001',
    title: 'Up to 60% OFF — Electronics Sale — Limited Time',
    imageUrl: MockImages.banner(10),
    actionUrl: '/explore?category=Electronics',
  ),
  BannerModel(
    id: 'banner_002',
    title: 'New Summer Collection — Fresh styles just arrived',
    imageUrl: MockImages.banner(20),
    actionUrl: '/explore?category=Fashion',
  ),
  BannerModel(
    id: 'banner_003',
    title: 'Free Shipping — On all orders above 2000 DZD',
    imageUrl: MockImages.banner(30),
    actionUrl: '/explore?sort=deals',
  ),
];
