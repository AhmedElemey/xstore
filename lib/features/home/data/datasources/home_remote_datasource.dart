import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/deal_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<BannerModel>> fetchBanners();

  Future<List<DealModel>> fetchHotDeals();

  Future<List<CategoryModel>> fetchCategories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiEndpoints.banners);
      final list = response.data ?? [];
      return list
          .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return _mockBanners();
      }
      throw _mapDio(e);
    }
  }

  @override
  Future<List<DealModel>> fetchHotDeals() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiEndpoints.hotDeals);
      final list = response.data ?? [];
      return list
          .map((e) => DealModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return _mockDeals();
      }
      throw _mapDio(e);
    }
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiEndpoints.categories);
      final list = response.data ?? [];
      return list
          .map(
            (e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return _mockCategories();
      }
      throw _mapDio(e);
    }
  }

  bool _isOffline(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  AppException _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(e.message);
      default:
        return ServerException(e.message);
    }
  }

  List<BannerModel> _mockBanners() => [
        const BannerModel(
          id: 'b1',
          title: 'New season',
          imageUrl: 'https://picsum.photos/seed/xstore1/800/360',
        ),
        const BannerModel(
          id: 'b2',
          title: 'Hot deals',
          imageUrl: 'https://picsum.photos/seed/xstore2/800/360',
        ),
      ];

  List<DealModel> _mockDeals() => [
        const DealModel(
          id: 'd1',
          title: 'Wireless buds',
          price: 49.99,
          imageUrl: 'https://picsum.photos/seed/deal1/400/400',
          discountPercent: 15,
        ),
        const DealModel(
          id: 'd2',
          title: 'Smart watch',
          price: 129,
          imageUrl: 'https://picsum.photos/seed/deal2/400/400',
          discountPercent: 10,
        ),
      ];

  List<CategoryModel> _mockCategories() => const [
        CategoryModel(id: 'c1', name: 'Electronics'),
        CategoryModel(id: 'c2', name: 'Fashion'),
        CategoryModel(id: 'c3', name: 'Home'),
        CategoryModel(id: 'c4', name: 'Sports'),
      ];
}
