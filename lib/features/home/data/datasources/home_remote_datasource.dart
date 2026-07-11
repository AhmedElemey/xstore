import 'package:dio/dio.dart';

import '../../../../core/mock/mock_banners.dart';
import '../../../../core/mock/mock_categories.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_deals.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
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

  /// Max tiles shown in the hot-deals carousel.
  static const int _hotDealsCount = 10;

  @override
  Future<List<BannerModel>> fetchBanners() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(List<BannerModel>.from(mockBannerModels));
    }
    // No banners endpoint exists in the backend (xStoreEcommerce API) —
    // the old GET /home/banners was never real. Serve the static set
    // locally until a real endpoint is added.
    return _staticBanners();
  }

  @override
  Future<List<DealModel>> fetchHotDeals() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(List<DealModel>.from(mockHotDealModels));
    }
    // No dedicated hot-deals endpoint exists — derive deals from
    // GET /api/listings: any listing with compareAtPrice > price is
    // discounted; biggest discounts first.
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListings,
        queryParameters: {'page': 1, 'pageSize': 40},
        options: ApiAuthHeaders.public(),
      );
      final deals = _unwrapObjectList(response.data)
          .map(_dealFromListing)
          .whereType<DealModel>()
          .toList()
        ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      return deals.take(_hotDealsCount).toList();
    } on DioException catch (e) {
      if (_isOffline(e)) return _fallbackDeals();
      throw mapDioException(e);
    }
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(List<CategoryModel>.from(mockCategoryModels));
    }
    try {
      // GET /api/categories returns a bare list of top-level categories,
      // each embedding its subcategories in `children` (see the catalog
      // categories datasource). Home chips only need the top level.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.catalogCategories,
        options: ApiAuthHeaders.public(),
      );
      return _unwrapObjectList(response.data)
          .map(_categoryFromApi)
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) return _fallbackCategories();
      throw mapDioException(e);
    }
  }

  /// Maps a listing-shaped API object to a deal tile; null when the
  /// listing carries no usable id/title.
  DealModel? _dealFromListing(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title =
        (json['title'] ?? json['titleEn'] ?? json['name'] ?? '').toString();
    if (id.isEmpty || title.isEmpty) return null;
    final price = _num(json['price']);
    final compare = _num(json['compareAtPrice'] ?? json['compare_at_price']);
    final discount = compare > price && compare > 0
        ? ((compare - price) / compare) * 100
        : 0.0;
    final images = json['imageUrls'];
    final imageUrl = images is List && images.isNotEmpty
        ? images.first?.toString()
        : json['imageUrl']?.toString();
    return DealModel(
      id: id,
      title: title,
      price: price,
      imageUrl: imageUrl,
      discountPercent: discount,
    );
  }

  CategoryModel _categoryFromApi(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['nameEn'] ?? json['name'] ?? json['nameAr'] ?? '').toString(),
      iconUrl: json['iconUrl']?.toString(),
    );
  }

  List<Map<String, dynamic>> _unwrapObjectList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final items = m['items'] ?? m['data'] ?? m['results'] ?? m['listings'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  bool _isOffline(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  List<BannerModel> _staticBanners() => [
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

  List<DealModel> _fallbackDeals() => [
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

  List<CategoryModel> _fallbackCategories() => const [
        CategoryModel(id: 'c1', name: 'Electronics'),
        CategoryModel(id: 'c2', name: 'Fashion'),
        CategoryModel(id: 'c3', name: 'Home'),
        CategoryModel(id: 'c4', name: 'Sports'),
      ];
}
