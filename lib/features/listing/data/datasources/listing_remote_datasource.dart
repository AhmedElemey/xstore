import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/listing_model.dart';

abstract interface class ListingRemoteDataSource {
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required double price,
    required List<String> imagePaths,
  });

  Future<List<ListingModel>> fetchMyListings();

  Future<ListingModel> updateListing({
    required String id,
    required String title,
    required String description,
    required double price,
    required String status,
  });

  Future<void> deleteListing(String id);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  ListingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Local scaffold cache when API is unavailable.
  final List<ListingModel> _localMine = [];

  @override
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required double price,
    required List<String> imagePaths,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.listings,
        data: {
          'title': title,
          'description': description,
          'price': price,
          'images': imagePaths,
        },
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
          title: title,
          description: description,
          price: price,
          status: 'pending',
          imageUrls: List<String>.from(imagePaths),
        );
        _localMine.insert(0, model);
        return model;
      }
      throw _mapDio(e);
    }
  }

  @override
  Future<List<ListingModel>> fetchMyListings() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiEndpoints.myListings);
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
      throw _mapDio(e);
    }
  }

  @override
  Future<ListingModel> updateListing({
    required String id,
    required String title,
    required String description,
    required double price,
    required String status,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.listings}/$id',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'status': status,
        },
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
          title: title,
          description: description,
          price: price,
          status: status,
        );
        _localMine[idx] = updated;
        return updated;
      }
      throw _mapDio(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _dio.delete<void>('${ApiEndpoints.listings}/$id');
      _localMine.removeWhere((e) => e.id == id);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        _localMine.removeWhere((e) => e.id == id);
        return;
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
}
