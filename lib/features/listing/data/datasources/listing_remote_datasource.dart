import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
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
    List<String> imagePaths = const [],
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
    required List<String> imagePaths,
    required ListingStatus status,
  });

  Future<void> deleteListing(String id);

  /// Sends a rejected listing back for review with a corrected price.
  /// CONFIRMED (Postman collection): unlike create/update, this is a plain
  /// JSON PUT — `{"newPrice": <double>}` — not multipart.
  Future<ListingModel> resubmitListing({
    required String id,
    required double newPrice,
  });

  /// Pauses a listing via the dedicated status-only endpoint. CONFIRMED
  /// (Postman collection) to exist as a plain PUT with no body — used
  /// instead of the generic multipart update so pausing never sends an
  /// empty `imageFiles` set (see `_listingFormData`'s image-wipe risk).
  Future<ListingModel> deactivateListing(String id);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  ListingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Local scaffold cache used only when a request genuinely can't reach
  /// the network (see [_isOffline]) — a resilience fallback, not mock data.
  final List<ListingModel> _localMine = [];

  /// Hard ceiling enforced at the network boundary regardless of what the
  /// form/draft-restore layers already did — no listing this datasource
  /// writes can ever carry more than this many photos.
  static const int _maxImagesPerListing = 5;

  // CONFIRMED against the xStoreEcommerce Postman collection (POST/PUT
  // Create/Update Listing): both write endpoints are multipart/form-data,
  // NOT flat JSON — the earlier "flat JSON, int condition" contract was
  // superseded. Attributes bind as an indexed list (`Attributes[i].Key` /
  // `Attributes[i].Value`, matching ASP.NET's default List<T> form
  // binder), and images attach inline as repeated `imageFiles` parts —
  // there is no separate pre-upload-then-URL step for listings.
  // `condition`/`status`/`subcategoryId` aren't shown in the collection's
  // example bodies but are kept here: extra unbound form keys are ignored
  // by ASP.NET model binding (confirmed pattern elsewhere in this repo),
  // and dropping them would silently break condition filtering / the
  // pause-resume status mutation if the backend DOES bind them.
  Future<FormData> _listingFormData({
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
    required List<String> imagePaths,
    String? id,
    ListingStatus? status,
  }) async {
    final fields = <String, dynamic>{
      if (id != null) 'id': id,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'price': price.toString(),
      if (compareAtPrice != null) 'compareAtPrice': compareAtPrice.toString(),
      'categoryId': categoryId.toString(),
      if (subcategoryId != null) 'subcategoryId': subcategoryId.toString(),
      'condition': listingConditionToWire(condition).toString(),
      if (brand.isNotEmpty) 'brand': brand,
      'stockQuantity': stockQuantity.toString(),
      'shippingAvailable': shippingAvailable.toString(),
      'shippingCost': shippingCost.toString(),
      'location': location,
      if (status != null) 'status': listingStatusToWire(status).toString(),
    };
    var i = 0;
    for (final entry in attributes.entries) {
      fields['Attributes[$i].Key'] = entry.key;
      fields['Attributes[$i].Value'] = entry.value;
      i++;
    }

    final formData = FormData.fromMap(fields);
    for (final path in imagePaths.take(_maxImagesPerListing)) {
      // photoPaths can be restored from a saved draft across app
      // sessions; the OS may evict image_picker's cache in the meantime.
      // Skip a stale path rather than let MultipartFile.fromFile throw
      // and hard-fail the whole submit over one missing photo.
      if (!File(path).existsSync()) continue;
      formData.files.add(
        MapEntry(
          'imageFiles',
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }
    return formData;
  }

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
    List<String> imagePaths = const [],
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiListings,
        data: await _listingFormData(
          titleEn: titleEn,
          titleAr: titleAr,
          descriptionEn: descriptionEn,
          descriptionAr: descriptionAr,
          price: price,
          compareAtPrice: compareAtPrice,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          condition: condition,
          brand: brand,
          stockQuantity: stockQuantity,
          shippingAvailable: shippingAvailable,
          shippingCost: shippingCost,
          location: location,
          attributes: attributes,
          imagePaths: imagePaths,
        ),
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
          // Offline scaffold only — imagePaths are local filesystem paths,
          // not hosted URLs, and imageUrls here feeds network-image
          // widgets, so it must stay empty until a real upload succeeds.
          imageUrls: const [],
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
    required List<String> imagePaths,
    required ListingStatus status,
  }) async {
    try {
      // Spec: id is sent in the BODY, PUT to the collection root — not
      // /api/listings/{id}. Confirmed from the Postman collection.
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.apiListings,
        data: await _listingFormData(
          id: id,
          titleEn: titleEn,
          titleAr: titleAr,
          descriptionEn: descriptionEn,
          descriptionAr: descriptionAr,
          price: price,
          compareAtPrice: compareAtPrice,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          condition: condition,
          brand: brand,
          stockQuantity: stockQuantity,
          shippingAvailable: shippingAvailable,
          shippingCost: shippingCost,
          location: location,
          attributes: attributes,
          imagePaths: imagePaths,
          status: status,
        ),
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
          status: listingStatusToWire(status).toString(),
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
          // imagePaths are local file paths (usually empty here — this
          // fallback only fires for status mutations); keep the cached
          // model's existing hosted imageUrls untouched via copyWith.
        );
        _localMine[idx] = updated;
        return updated;
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      // CONFIRMED (Postman collection): there is no DELETE endpoint for
      // listings — only /cancel and /deactivate exist. "Delete listing"
      // in the UI maps to /cancel (see ApiEndpoints.apiListingCancel for
      // why not /deactivate). This is a soft, terminal status change on
      // the backend, not a hard row delete.
      await _dio.put<void>(
        ApiEndpoints.apiListingCancel(id),
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

  @override
  Future<ListingModel> resubmitListing({
    required String id,
    required double newPrice,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.apiListingResubmit(id),
        data: {'newPrice': newPrice},
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      final model = ListingModel.fromJson(data);
      final idx = _localMine.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _localMine[idx] = model;
      }
      return model;
    } on DioException catch (e) {
      if (_isOffline(e)) {
        // Only meaningful when the listing is already cached locally
        // (created/updated earlier while offline) — resubmit only
        // receives `id` + `newPrice`, not enough to fabricate a full
        // listing from scratch the way createListing's offline scaffold
        // can. If it's not cached, there's nothing safe to return.
        final idx = _localMine.indexWhere((e) => e.id == id);
        if (idx != -1) {
          final updated = _localMine[idx].copyWith(
            price: newPrice,
            status: listingStatusToWire(ListingStatus.pending).toString(),
            rejectionReason: null,
          );
          _localMine[idx] = updated;
          return updated;
        }
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<ListingModel> deactivateListing(String id) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.apiListingDeactivate(id),
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      final model = ListingModel.fromJson(data);
      final idx = _localMine.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _localMine[idx] = model;
      }
      return model;
    } on DioException catch (e) {
      if (_isOffline(e)) {
        // Same caveat as resubmitListing above: only meaningful if the
        // listing is already in the local cache.
        final idx = _localMine.indexWhere((e) => e.id == id);
        if (idx != -1) {
          final updated = _localMine[idx].copyWith(
            status: listingStatusToWire(ListingStatus.paused).toString(),
          );
          _localMine[idx] = updated;
          return updated;
        }
      }
      throw mapDioException(e);
    }
  }

  bool _isOffline(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }
}
