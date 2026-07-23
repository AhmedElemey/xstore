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
import '../../domain/entities/update_profile_request.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(UserEntity sessionUser);

  /// Buyer-facing store head + stats (no auth).
  Future<ProfileModel> getVendorStoreProfile(String sellerId);

  Future<UserModel> updateProfile(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  });

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
/// Matches backend `UpdateProfileRequest` (camelCase JSON). Email/phone are
/// omitted — the backend contract marks them commented-out. [UserImage] and
/// [StoreImage] files are attached in [updateProfileFormData].
String? _optTrimmed(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _birthDateWire(DateTime? date) {
  if (date == null) return null;
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Wire map for PUT `/api/auth/update-profile` (camelCase JSON fields).
/// Exposed for unit tests; live calls use [updateProfileFormData].
Map<String, dynamic> updateProfileWireFields(UpdateProfileRequest request) {
  return {
    if (_optTrimmed(request.fullNameEn) != null)
      'fullNameEn': _optTrimmed(request.fullNameEn),
    if (_optTrimmed(request.fullNameAr) != null)
      'fullNameAr': _optTrimmed(request.fullNameAr),
    'userImageUrl': request.userImageUrl,
    'storeImageUrl': request.storeImageUrl,
    if (_optTrimmed(request.storeNameEn) != null)
      'storeNameEn': _optTrimmed(request.storeNameEn),
    if (_optTrimmed(request.storeNameAr) != null)
      'storeNameAr': _optTrimmed(request.storeNameAr),
    if (_optTrimmed(request.storeDescriptionEn) != null)
      'storeDescriptionEn': _optTrimmed(request.storeDescriptionEn),
    if (_optTrimmed(request.storeDescriptionAr) != null)
      'storeDescriptionAr': _optTrimmed(request.storeDescriptionAr),
    if (_optTrimmed(request.whatsAppNumber) != null)
      'whatsAppNumber': _optTrimmed(request.whatsAppNumber),
    if (_optTrimmed(request.instagramPage) != null)
      'instagramPage': _optTrimmed(request.instagramPage),
    if (_optTrimmed(request.facebookPage) != null)
      'facebookPage': _optTrimmed(request.facebookPage),
    if (_optTrimmed(request.detailedAddressByGoogleMaps) != null)
      'detailedAddressByGoogleMaps':
          _optTrimmed(request.detailedAddressByGoogleMaps),
    if (_optTrimmed(request.detailedAddressByUser) != null)
      'detailedAddressByUser': _optTrimmed(request.detailedAddressByUser),
    if (_optTrimmed(request.cityByGoogleMaps) != null)
      'cityByGoogleMaps': _optTrimmed(request.cityByGoogleMaps),
    if (_optTrimmed(request.governmentByGoogleMaps) != null)
      'governmentByGoogleMaps': _optTrimmed(request.governmentByGoogleMaps),
    if (request.lat != null) 'lat': request.lat,
    if (request.lng != null) 'lng': request.lng,
    if (request.storeCategoryId != null)
      'storeCategoryId': request.storeCategoryId,
    if (request.cityId != null) 'cityId': request.cityId,
    if (request.governmentId != null) 'governmentId': request.governmentId,
    if (request.birthDate != null)
      'birthDate': _birthDateWire(request.birthDate),
  };
}

Future<FormData> updateProfileFormData(UpdateProfileRequest request) async {
  final map = Map<String, dynamic>.from(updateProfileWireFields(request));
  final userImagePath = request.userImagePath?.trim();
  if (userImagePath != null && userImagePath.isNotEmpty) {
    map['userImage'] = await MultipartFile.fromFile(
      userImagePath,
      filename: userImagePath.split('/').last,
    );
  }
  final storeImagePath = request.storeImagePath?.trim();
  if (storeImagePath != null && storeImagePath.isNotEmpty) {
    map['storeImage'] = await MultipartFile.fromFile(
      storeImagePath,
      filename: storeImagePath.split('/').last,
    );
  }
  return FormData.fromMap(map);
}

UserEntity _entityFromUpdateRequest(
  UpdateProfileRequest request,
  UserEntity session,
) {
  return session.copyWith(
    name: request.fullNameEn ?? session.name,
    fullNameEn: request.fullNameEn ?? session.fullNameEn,
    fullNameAr: request.fullNameAr ?? session.fullNameAr,
    avatarUrl: request.userImageUrl,
    storeLogoUrl: request.storeImageUrl,
    storeNameEn: request.storeNameEn ?? session.storeNameEn,
    storeNameAr: request.storeNameAr ?? session.storeNameAr,
    storeName: request.storeNameEn ?? session.storeName,
    storeDescriptionEn:
        request.storeDescriptionEn ?? session.storeDescriptionEn,
    storeDescriptionAr:
        request.storeDescriptionAr ?? session.storeDescriptionAr,
    storeDescription: request.storeDescriptionEn ?? session.storeDescription,
    whatsappNumber: request.whatsAppNumber ?? session.whatsappNumber,
    instagramHandle: request.instagramPage ?? session.instagramHandle,
    facebookPage: request.facebookPage ?? session.facebookPage,
    location: request.detailedAddressByGoogleMaps ?? session.location,
    detailAddress: request.detailedAddressByUser ?? session.detailAddress,
    town: request.cityByGoogleMaps ?? session.town,
    governorate: request.governmentByGoogleMaps ?? session.governorate,
    latitude: request.lat ?? session.latitude,
    longitude: request.lng ?? session.longitude,
    storeCategoryId: request.storeCategoryId ?? session.storeCategoryId,
    storeCityId: request.cityId ?? session.storeCityId,
    storeGovernmentId: request.governmentId ?? session.storeGovernmentId,
    dateOfBirth: request.birthDate ?? session.dateOfBirth,
  );
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
      storeId: session.storeId ?? base.storeId,
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
      // Keep the session's role: this branch also serves courier sessions
      // (mock driver login) — forcing consumer here would silently downgrade
      // them on every profile refresh.
      role: session.role,
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
      storeId: user.storeId,
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
      final wire = parseProfileResponse(data);
      final user = userModelFromProfileResponse(
        data,
        fallbackUserId: sessionUser.id,
      );
      // ASSUMPTION: get-profile returns identity fields only — no confirmed
      // backend source yet for orders/wishlist/store stats. Default to 0
      // until a real source exists (Phase 2, once listings/orders land).
      return ProfileModel(
        user: user,
        isEmailVerificationRequired: wire.isEmailVerificationRequired,
        isPhoneVerificationRequired: wire.isPhoneVerificationRequired,
      );
    } on FormatException {
      throw const ServerException('Empty profile');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> updateProfile(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  }) async {
    if (MockConfig.useMock) {
      var merged = _entityFromUpdateRequest(request, sessionUser);
      final userImagePath = request.userImagePath?.trim();
      if (userImagePath != null && userImagePath.isNotEmpty) {
        merged = merged.copyWith(avatarUrl: MockImages.avatar(98));
      }
      final storeImagePath = request.storeImagePath?.trim();
      if (storeImagePath != null && storeImagePath.isNotEmpty) {
        merged = merged.copyWith(storeLogoUrl: MockImages.avatar(99));
      }
      final model = await MockConfig.simulate(
        _mockUserModelFromEntity(merged),
      );
      return model;
    }
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.updateProfile,
        data: await updateProfileFormData(request),
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return userModelFromProfileResponse(
        data,
        fallbackUserId: sessionUser.id,
      );
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
      // Multipart upload of the picked image. Field name `profileImage`
      // mirrors the only CONFIRMED image field in this backend (vendor
      // register — see auth_remote_datasource). The route is token-scoped
      // (the X-Auth-Token interceptor identifies the user), so `userId` is
      // not sent — it stays on the signature in case the route ever becomes
      // user-scoped. Returns the stored avatar URL, which the caller then
      // persists via update-profile's `avatarUrl`.
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          filePath,
          // image_picker returns POSIX-style paths on iOS/Android.
          filename: filePath.split('/').last,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadAvatar,
        data: formData,
        options: ApiAuthHeaders.authenticated(),
      );
      final url = _avatarUrlFromResponse(response.data);
      if (url == null || url.isEmpty) {
        throw const ServerException('Avatar upload returned no URL.');
      }
      return url;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Reads the uploaded avatar URL from tolerant response shapes: a bare
  /// `{avatarUrl|url|imageUrl}`, or a `{user:{avatarUrl}}` profile wrapper.
  String? _avatarUrlFromResponse(Map<String, dynamic>? data) {
    if (data == null) return null;
    final direct = data['avatarUrl'] ?? data['url'] ?? data['imageUrl'];
    if (direct is String && direct.isNotEmpty) return direct;
    final user = data['user'];
    if (user is Map) {
      final nested = user['avatarUrl'];
      if (nested is String && nested.isNotEmpty) return nested;
    }
    return null;
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
