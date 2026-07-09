import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/listing_entity.dart';
import '../models/listing_model.dart';

abstract interface class ListingRemoteDataSource {
  Future<ListingModel> createListing({
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    List<String> imageUrls = const [],
  });

  Future<List<ListingModel>> fetchMyListings();

  Future<ListingModel> updateListing({
    required String id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    required List<String> imageUrls,
    required ListingStatus status,
  });

  Future<void> deleteListing(String id);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  ListingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Local scaffold cache when API is unavailable.
  final List<ListingModel> _localMine = [];

  /// Mutable mock catalog when [MockConfig.useMock] is true.
  List<ListingModel>? _mockMine;

  List<ListingModel> get _mockList =>
      _mockMine ??= List<ListingModel>.from(mockListingModels);

  @override
  Future<ListingModel> createListing({
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    List<String> imageUrls = const [],
  }) async {
    if (MockConfig.useMock) {
      final model = ListingModel(
        id: 'listing_${DateTime.now().microsecondsSinceEpoch}',
        title: titleEn,
        description: descriptionEn,
        price: price,
        status: 'pending',
        imageUrls: imageUrls,
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        compareAtPrice: compareAtPrice,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: listingConditionToDto(condition),
        brand: brand,
        stockQuantity: stockQuantity,
        shippingAvailable: shippingAvailable,
        shippingCost: shippingCost,
        location: location,
        attributes: attributes,
      );
      _mockList.insert(0, model);
      return MockConfig.simulate(model);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiListings,
        data: {
          'titleEn': titleEn,
          'titleAr': titleAr,
          'descriptionEn': descriptionEn,
          'descriptionAr': descriptionAr,
          'price': price,
          'compareAtPrice': compareAtPrice,
          'categoryId': categoryId,
          'subcategoryId': subcategoryId,
          'condition': listingConditionToDto(condition),
          'brand': brand,
          'stockQuantity': stockQuantity,
          'shippingAvailable': shippingAvailable,
          'shippingCost': shippingCost,
          'location': location,
          'attributes': attributes,
          // NOTE (known gap): no image-upload endpoint exists in the
          // backend yet. Always empty until one is confirmed and wired.
          'imageUrls': imageUrls,
        },
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      final model = ListingModel.fromJson(data);
      _localMine.insert(0, model);
      return model;
    } on DioException catch (e) {
      if (_isOffline(e)) {
        final model = ListingModel(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          title: titleEn,
          description: descriptionEn,
          price: price,
          status: 'pending',
          imageUrls: imageUrls,
          titleEn: titleEn,
          titleAr: titleAr,
          descriptionEn: descriptionEn,
          descriptionAr: descriptionAr,
          compareAtPrice: compareAtPrice,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          condition: listingConditionToDto(condition),
          brand: brand,
          stockQuantity: stockQuantity,
          shippingAvailable: shippingAvailable,
          shippingCost: shippingCost,
          location: location,
          attributes: attributes,
        );
        _localMine.insert(0, model);
        return model;
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<List<ListingModel>> fetchMyListings() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(List<ListingModel>.from(_mockList));
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.apiMyListings,
        options: ApiAuthHeaders.authenticated(),
      );
      final list = response.data ?? [];
      final remote = list
          .map(
            (e) => ListingModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
      return List<ListingModel>.from(_localMine);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return List<ListingModel>.from(_localMine);
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<ListingModel> updateListing({
    required String id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    required List<String> imageUrls,
    required ListingStatus status,
  }) async {
    if (MockConfig.useMock) {
      final idx = _mockList.indexWhere((e) => e.id == id);
      if (idx == -1) {
        throw const ServerException('Listing not found');
      }
      final updated = _mockList[idx].copyWith(
        title: titleEn,
        description: descriptionEn,
        price: price,
        status: _statusToDto(status),
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        compareAtPrice: compareAtPrice,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: listingConditionToDto(condition),
        brand: brand,
        stockQuantity: stockQuantity,
        shippingAvailable: shippingAvailable,
        shippingCost: shippingCost,
        location: location,
        attributes: attributes,
        imageUrls: imageUrls,
      );
      _mockList[idx] = updated;
      return MockConfig.simulate(updated);
    }
    try {
      // Spec: id is sent in the BODY, PUT to the collection root — not
      // /api/listings/{id}. Confirmed from the Postman collection.
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.apiListings,
        data: {
          'id': id,
          'titleEn': titleEn,
          'titleAr': titleAr,
          'descriptionEn': descriptionEn,
          'descriptionAr': descriptionAr,
          'price': price,
          'compareAtPrice': compareAtPrice,
          'categoryId': categoryId,
          'subcategoryId': subcategoryId,
          'condition': listingConditionToDto(condition),
          'brand': brand,
          'stockQuantity': stockQuantity,
          'shippingAvailable': shippingAvailable,
          'shippingCost': shippingCost,
          'location': location,
          'attributes': attributes,
          'imageUrls': imageUrls,
          'status': _statusToDto(status),
        },
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return ListingModel.fromJson(data);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        final idx = _localMine.indexWhere((e) => e.id == id);
        if (idx == -1) {
          throw const ServerException('Listing not found');
        }
        final updated = _localMine[idx].copyWith(
          title: titleEn,
          description: descriptionEn,
          price: price,
          status: _statusToDto(status),
          titleEn: titleEn,
          titleAr: titleAr,
          descriptionEn: descriptionEn,
          descriptionAr: descriptionAr,
          compareAtPrice: compareAtPrice,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          condition: listingConditionToDto(condition),
          brand: brand,
          stockQuantity: stockQuantity,
          shippingAvailable: shippingAvailable,
          shippingCost: shippingCost,
          location: location,
          attributes: attributes,
          imageUrls: imageUrls,
        );
        _localMine[idx] = updated;
        return updated;
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    if (MockConfig.useMock) {
      _mockList.removeWhere((e) => e.id == id);
      await MockConfig.simulate(0);
      return;
    }
    try {
      await _dio.delete<void>(
        ApiEndpoints.apiListingDetail(id),
        options: ApiAuthHeaders.authenticated(),
      );
      _localMine.removeWhere((e) => e.id == id);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        _localMine.removeWhere((e) => e.id == id);
        return;
      }
      throw mapDioException(e);
    }
  }

  bool _isOffline(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  String _statusToDto(ListingStatus status) {
    switch (status) {
      case ListingStatus.pending:
        return 'pending';
      case ListingStatus.active:
        return 'active';
      case ListingStatus.draft:
        return 'draft';
      case ListingStatus.paused:
        return 'paused';
      case ListingStatus.sold:
        return 'sold';
      case ListingStatus.rejected:
        return 'rejected';
    }
  }
}
