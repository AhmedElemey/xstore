import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/legacy_route_options.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../listing/data/models/listing_model.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(UserEntity sessionUser);

  /// Buyer-facing store head + stats (no auth).
  Future<ProfileModel> getVendorStoreProfile(String sellerId);

  Future<UserModel> updateProfile(UserEntity updated);

  Future<String> updateAvatar({required String userId, required String filePath});

  Future<void> deleteAccount();

  Future<List<ListingEntity>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  });
}

/// PUT `/api/auth/update-profile` body keys.
///
/// Write aliases confirmed in this repo: [whatsAppNumber], [instagramPage].
/// Other keys match live get-profile / [UserModel.fromJson] field names
/// (e.g. [birthDate] on the wire vs internal `dateOfBirth`).
Map<String, dynamic> updateProfileRequestBody(UserEntity updated) {
  return {
    'fullNameEn': updated.fullNameEn ?? updated.name,
    'fullNameAr': updated.fullNameAr ?? updated.name,
    'email': updated.email,
    'phoneNumber': updated.phoneNumber,
    // Always present so an explicit null clears the avatar on the server.
    'avatarUrl': updated.avatarUrl,
    if (updated.bio != null) 'bio': updated.bio,
    if (updated.location != null) 'location': updated.location,
    if (updated.dateOfBirth != null)
      'birthDate': updated.dateOfBirth!.toIso8601String(),
    if (updated.storeNameEn != null) 'storeNameEn': updated.storeNameEn,
    if (updated.storeNameAr != null) 'storeNameAr': updated.storeNameAr,
    if (updated.storeDescriptionEn != null)
      'storeDescriptionEn': updated.storeDescriptionEn,
    if (updated.storeDescriptionAr != null)
      'storeDescriptionAr': updated.storeDescriptionAr,
    if (updated.storeCategory != null) 'storeCategory': updated.storeCategory,
    if (updated.storeCategoryId != null)
      'storeCategoryId': updated.storeCategoryId,
    if (updated.storeCity != null) 'storeCity': updated.storeCity,
    if (updated.storeWilaya != null) 'storeWilaya': updated.storeWilaya,
    if (updated.latitude != null) 'latitude': updated.latitude,
    if (updated.longitude != null) 'longitude': updated.longitude,
    if (updated.governorate != null) 'governorate': updated.governorate,
    if (updated.town != null) 'town': updated.town,
    if (updated.detailAddress != null) 'detailAddress': updated.detailAddress,
    if (updated.whatsappNumber != null)
      'whatsAppNumber': updated.whatsappNumber,
    if (updated.instagramHandle != null)
      'instagramPage': updated.instagramHandle,
    if (updated.facebookPage != null) 'facebookPage': updated.facebookPage,
  };
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static bool _isLegacyRouteMissing(DioException e) =>
      e.response?.statusCode == 404;

  Options get _legacyOptions => LegacyRouteOptions.allowNotFound();

  ProfileModel _fallbackVendorStoreProfile(String sellerId) {
    return ProfileModel(
      user: UserModel(
        id: sellerId,
        name: '',
        email: '',
        phoneNumber: '',
        role: UserRole.vendor,
      ),
    );
  }

  UserEntity _mergeVendorMock(UserEntity session) {
    final base = mockVendorUser;
    return session.copyWith(
      name: session.name.isNotEmpty ? session.name : base.name,
      email: session.email,
      phoneNumber:
          session.phoneNumber.isNotEmpty ? session.phoneNumber : base.phoneNumber,
      avatarUrl: session.avatarUrl ?? MockImages.avatar(1),
      role: UserRole.vendor,
      isVerified: true,
      rating: base.rating,
      totalSales: base.totalSales,
      joinedAt: session.joinedAt ?? DateTime(2023, 3, 15),
      location: session.location ?? base.location,
      storeName: session.storeName ?? base.storeName,
      storeSlug: session.storeSlug ?? base.storeSlug,
      storeCategory: session.storeCategory ?? base.storeCategory,
      storeDescription: session.storeDescription ?? base.storeDescription,
      storeLogoUrl: session.storeLogoUrl,
      storeCity: session.storeCity ?? base.storeCity,
      storeWilaya: session.storeWilaya ?? base.storeWilaya,
      whatsappNumber: session.whatsappNumber ?? base.whatsappNumber,
    );
  }

  UserEntity _mergeConsumerMock(UserEntity session) {
    final base = mockConsumerUser;
    return session.copyWith(
      name: session.name.isNotEmpty ? session.name : base.name,
      email: session.email,
      phoneNumber:
          session.phoneNumber.isNotEmpty ? session.phoneNumber : base.phoneNumber,
      avatarUrl: session.avatarUrl ?? MockImages.avatar(2),
      role: UserRole.consumer,
      isVerified: session.isVerified,
      joinedAt: session.joinedAt ?? DateTime(2024, 1, 10),
      location: session.location ?? base.location,
    );
  }

  /// Maps every profile field for mock get/update so save→fetch round-trips.
  UserModel _mockUserModelFromEntity(UserEntity user, {String? token}) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isVerified: user.isVerified,
      rating: user.rating,
      totalSales: user.totalSales,
      joinedAt: user.joinedAt,
      location: user.location,
      storeName: user.storeName,
      storeSlug: user.storeSlug,
      storeCategory: user.storeCategory,
      storeDescription: user.storeDescription,
      storeLogoUrl: user.storeLogoUrl,
      storeCity: user.storeCity,
      storeWilaya: user.storeWilaya,
      whatsappNumber: user.whatsappNumber,
      latitude: user.latitude,
      longitude: user.longitude,
      governorate: user.governorate,
      town: user.town,
      detailAddress: user.detailAddress,
      bio: user.bio,
      dateOfBirth: user.dateOfBirth,
      instagramHandle: user.instagramHandle,
      facebookPage: user.facebookPage,
      token: token,
      fullNameEn: user.fullNameEn,
      fullNameAr: user.fullNameAr,
      storeNameEn: user.storeNameEn,
      storeNameAr: user.storeNameAr,
      storeDescriptionEn: user.storeDescriptionEn,
      storeDescriptionAr: user.storeDescriptionAr,
      storeCategoryId: user.storeCategoryId,
      storeCityId: user.storeCityId,
      storeGovernmentId: user.storeGovernmentId,
    );
  }

  @override
  Future<ProfileModel> getVendorStoreProfile(String sellerId) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(Duration.zero);
      if (sellerId != mockVendorUser.id && sellerId != 'vendor_001') {
        throw const ServerException('Store not found');
      }
      final user = _mergeVendorMock(mockVendorUser);
      return ProfileModel(
        user: _mockUserModelFromEntity(user),
        storeViewCount: 2400,
        storeSaveCount: 89,
        storeActiveListings: 18,
        responseRatePercent: 89,
      );
    }
    try {
      // NOT in the confirmed backend contract — no public store-profile
      // route exists in the xStoreEcommerce API yet; fails until added.
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.users}/$sellerId/store',
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        return _fallbackVendorStoreProfile(sellerId);
      }
      final data = response.data;
      if (data == null) throw const ServerException('Empty store');
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return ProfileModel(
        user: user,
        storeViewCount: data['storeViewCount'] as int? ?? 0,
        storeSaveCount: data['storeSaveCount'] as int? ?? 0,
        storeActiveListings: data['storeActiveListings'] as int? ?? 0,
        responseRatePercent: data['responseRatePercent'] as int? ?? 0,
      );
    } on DioException catch (e) {
      if (_isLegacyRouteMissing(e)) {
        return _fallbackVendorStoreProfile(sellerId);
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<ProfileModel> getProfile(UserEntity sessionUser) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(Duration.zero);
      if (sessionUser.role == UserRole.vendor) {
        final user = _mergeVendorMock(sessionUser);
        return ProfileModel(
          user: _mockUserModelFromEntity(user),
          storeViewCount: 2400,
          storeSaveCount: 89,
          storeActiveListings: 18,
          responseRatePercent: 89,
        );
      }
      final user = _mergeConsumerMock(sessionUser);
      return ProfileModel(
        user: _mockUserModelFromEntity(user),
        ordersCount: 12,
        wishlistCount: 5,
        savedAmountDzd: 23000,
      );
    }
    try {
      // GET /api/auth/get-profile — identifies the user via the auth token,
      // not sessionUser.id. CONFIRMED live shape: `{"user":{...},"store":...}`
      // (same wrapper as update-profile); see [parseProfileUserJson].
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.getProfile,
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty profile');
      final user = UserModel.fromJson(parseProfileUserJson(data));
      // ASSUMPTION: get-profile returns identity fields only — no confirmed
      // backend source yet for orders/wishlist/store stats. Default to 0
      // until a real source exists (Phase 2, once listings/orders land).
      return ProfileModel(user: user);
    } on FormatException {
      throw const ServerException('Empty profile');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> updateProfile(UserEntity updated) async {
    if (MockConfig.useMock) {
      final model = await MockConfig.simulate(
        _mockUserModelFromEntity(updated),
      );
      return model;
    }
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.updateProfile,
        data: updateProfileRequestBody(updated),
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return UserModel.fromJson(parseProfileUserJson(data));
    } on FormatException {
      throw const ServerException('Empty response');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<String> updateAvatar({
    required String userId,
    required String filePath,
  }) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(MockImages.avatar(99));
    }
    try {
      // NOT in the confirmed backend contract — no image-upload route
      // exists in the xStoreEcommerce API yet (same gap as listing images).
      await _dio.post<void>('${ApiEndpoints.users}/$userId/avatar');
      return MockImages.avatar(99);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(MockConfig.mockDelay);
      return;
    }
    try {
      // NOT in the confirmed backend contract — no account-delete route
      // exists in the xStoreEcommerce API yet.
      await _dio.delete<void>('${ApiEndpoints.users}/me');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<ListingEntity>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(Duration.zero);
      if (sellerId != mockVendorUser.id && sellerId != 'vendor_001') {
        return [];
      }
      var rows = mockListingModels
          .where((e) => e.status.toLowerCase() == 'active')
          .toList();
      if (categoryLabel != null &&
          categoryLabel.isNotEmpty &&
          categoryLabel != 'all') {
        rows = rows
            .where(
              (e) =>
                  e.categoryLabel.toLowerCase() ==
                  categoryLabel.toLowerCase(),
            )
            .toList();
      }
      final start = page * pageSize;
      if (start >= rows.length) return [];
      final slice = rows.skip(start).take(pageSize).toList();
      return slice.map((e) => e.toEntity()).toList();
    }
    try {
      // NOT in the confirmed backend contract — /api/listings has no
      // seller filter, so a buyer can't fetch another vendor's listings yet.
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.users}/$sellerId/listings',
        queryParameters: {
          if (categoryLabel != null) 'category': categoryLabel,
          'page': page,
          'pageSize': pageSize,
        },
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return [];
      final list = response.data?['items'] as List<dynamic>? ?? [];
      return list
          .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e as Map)).toEntity())
          .toList();
    } on DioException catch (e) {
      if (_isLegacyRouteMissing(e)) return [];
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
