import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
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

  Future<String> updateAvatar({
    required String userId,
    required String filePath,
  });

  Future<void> deleteAccount({
    required String password,
    required String confirmationText,
  });

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
      'fullName': _optTrimmed(request.fullNameEn),
    'userImageUrl': request.userImageUrl,
    'storeImageUrl': request.storeImageUrl,
    if (_optTrimmed(request.storeName) != null)
      'storeName': _optTrimmed(request.storeName),
    if (_optTrimmed(request.storeDescription) != null)
      'storeDescription': _optTrimmed(request.storeDescription),
    if (_optTrimmed(request.whatsAppNumber) != null)
      'whatsAppNumber': _optTrimmed(request.whatsAppNumber),
    if (_optTrimmed(request.instagramPage) != null)
      'instagramPage': _optTrimmed(request.instagramPage),
    if (_optTrimmed(request.facebookPage) != null)
      'facebookPage': _optTrimmed(request.facebookPage),
    if (_optTrimmed(request.detailedAddressByGoogleMaps) != null)
      'detailedAddressByGoogleMaps': _optTrimmed(
        request.detailedAddressByGoogleMaps,
      ),
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
    if (request.governorateId != null) 'governorateId': request.governorateId,
    if (request.birthDate != null)
      'birthDate': _birthDateWire(request.birthDate),
  };
}

void _debugLogProfileFields({
  required String tag,
  Map<String, dynamic>? wireFields,
  Map<String, dynamic>? responseData,
  UserModel? parsed,
}) {
  if (!kDebugMode) return;

  dynamic readNested(Map<String, dynamic>? data, String path) {
    if (data == null) return null;
    dynamic cur = data;
    for (final part in path.split('.')) {
      if (cur is! Map) return null;
      cur = cur[part];
    }
    return cur;
  }

  bool valuesMatch(dynamic sent, dynamic got) {
    if (got == null) return sent == null;
    final s = sent.toString().trim();
    final g = got.toString().trim();
    if (s == g) return true;
    if (s.length >= 10 &&
        g.length >= 10 &&
        s.substring(0, 10) == g.substring(0, 10)) {
      return true;
    }
    final sd = double.tryParse(s);
    final gd = double.tryParse(g);
    if (sd != null && gd != null) return (sd - gd).abs() < 0.0001;
    return false;
  }

  /// PUT wire key → get-profile response path (user.* or store.*).
  const fieldMap = <String, String>{
    'fullName': 'user.fullName',
    'birthDate': 'user.birthDate',
    'userImageUrl': 'user.avatarUrl',
    'storeName': 'store.name',
    'storeDescription': 'store.description',
    'storeImageUrl': 'store.storeLogoUrl',
    'whatsAppNumber': 'store.whatsAppNumber',
    'instagramPage': 'store.instagramPage',
    'facebookPage': 'store.facebookPage',
    'detailedAddressByGoogleMaps': 'store.detailedAddressByGoogleMaps',
    'detailedAddressByUser': 'store.detailedAddressByUser',
    'cityByGoogleMaps': 'store.cityByGoogleMaps',
    'governmentByGoogleMaps': 'store.governmentByGoogleMaps',
    'lat': 'store.lat',
    'lng': 'store.lng',
    'storeCategoryId': 'store.storeCategoryId',
    'cityId': 'store.cityId',
    'governorateId': 'store.governorateId',
  };

  debugPrint('── profile $tag ──');
  if (wireFields != null) {
    final sentKeys = wireFields.keys
        .where((k) => k != 'userImage' && k != 'storeImage')
        .toList();
    debugPrint('PUT wire keys (${sentKeys.length}): $sentKeys');
    for (final fileKey in ['userImage', 'storeImage']) {
      if (wireFields.containsKey(fileKey)) {
        debugPrint('PUT file: $fileKey attached');
      }
    }
  }

  if (wireFields != null && responseData != null && responseData.isNotEmpty) {
    debugPrint('── field sync (sent → response raw) ──');
    for (final entry in fieldMap.entries) {
      if (!wireFields.containsKey(entry.key)) continue;
      final sent = wireFields[entry.key];
      final got = readNested(responseData, entry.value);
      final synced = valuesMatch(sent, got);
      debugPrint('  ${synced ? "✓" : "✗"} ${entry.key}: sent=$sent → got=$got');
    }
  }

  if (parsed != null) {
    debugPrint(
      'parsed model: name=${parsed.name} dateOfBirth=${parsed.dateOfBirth} '
      'storeDescription=${parsed.storeDescription} storeName=${parsed.storeName}',
    );
  }
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
    storeName: request.storeName ?? session.storeName,
    storeDescription: request.storeDescription ?? session.storeDescription,
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
    storeGovernmentId: request.governorateId ?? session.storeGovernmentId,
    dateOfBirth: request.birthDate ?? session.dateOfBirth,
  );
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Catalog listing JSON for one public seller. Shared by store head + grid
  /// so Visit Store does not GET /api/listings twice.
  String? _publicSellerId;
  List<Map<String, dynamic>>? _publicSellerMaps;

  UserEntity _mergeVendorMock(UserEntity session) {
    final base = mockVendorUser;
    return session.copyWith(
      name: session.name.isNotEmpty ? session.name : base.name,
      email: session.email,
      phoneNumber: session.phoneNumber.isNotEmpty
          ? session.phoneNumber
          : base.phoneNumber,
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
      phoneNumber: session.phoneNumber.isNotEmpty
          ? session.phoneNumber
          : base.phoneNumber,
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
      // `/users/{id}/store` is not on the live API. Public storefronts are
      // assembled from GET /api/listings (same catalog as home/explore),
      // filtered by listing `userId`. Drop the per-seller cache so pull-to-
      // refresh refetches; fetchVendorStoreListings then reuses this result.
      _publicSellerId = null;
      _publicSellerMaps = null;
      final maps = await _publicListingMapsForSeller(sellerId);
      final first = maps.isNotEmpty ? maps.first : null;
      final storeName = first == null
          ? null
          : _optJsonString(first, 'storeName');
      final userName = first == null ? null : _optJsonString(first, 'userName');
      final avatar = first == null
          ? null
          : (_optJsonString(first, 'userAvatar') ??
                _optJsonString(first, 'storeImageUrl'));
      final name = storeName ?? userName ?? sellerId;
      return ProfileModel(
        user: UserModel(
          id: sellerId,
          name: name,
          email: '',
          role: UserRole.vendor,
          storeName: storeName ?? userName,
          storeLogoUrl: avatar,
          avatarUrl: avatar,
          location: first == null ? null : _optJsonString(first, 'location'),
        ),
        storeActiveListings: maps.length,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
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
      _debugLogProfileFields(
        tag: 'GET get-profile',
        responseData: data,
        parsed: user,
      );
      // ASSUMPTION: get-profile returns identity fields only — no confirmed
      // backend source yet for orders/wishlist/store stats. Default to 0
      // until a real source exists (Phase 2, once listings/orders land).
      return ProfileModel(
        user: user,
        isEmailVerificationRequired: wire.isEmailVerificationRequired,
        isPhoneVerificationRequired: wire.isPhoneVerificationRequired,
        isEmailVerified: wire.isEmailVerified,
        isPhoneVerified: wire.isPhoneVerified,
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
      final model = await MockConfig.simulate(_mockUserModelFromEntity(merged));
      return model;
    }
    try {
      final wireFields = updateProfileWireFields(request);
      _debugLogProfileFields(
        tag: 'PUT update-profile (request)',
        wireFields: wireFields,
      );
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.updateProfile,
        data: await updateProfileFormData(request),
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      final parsed = userModelFromProfileResponse(
        data,
        fallbackUserId: sessionUser.id,
      );
      _debugLogProfileFields(
        tag: 'PUT update-profile (response ${response.statusCode})',
        wireFields: wireFields,
        responseData: data,
        parsed: parsed,
      );
      return parsed;
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
      // Multipart upload via the generic uploads endpoint. CONFIRMED
      // (Postman collection): POST /api/uploads/{entityType}, file field
      // key `file` — supersedes the old /api/auth/avatar + `profileImage`
      // guess, which was never confirmed against the backend. The route
      // is token-scoped (the X-Auth-Token interceptor identifies the
      // user), so `userId` is not sent — it stays on the signature in
      // case the route ever becomes user-scoped. Returns the stored
      // avatar URL, which the caller then persists via update-profile's
      // `avatarUrl`.
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          // image_picker returns POSIX-style paths on iOS/Android.
          filename: filePath.split('/').last,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiUpload('avatar'),
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
  Future<void> deleteAccount({
    required String password,
    required String confirmationText,
  }) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(MockConfig.mockDelay);
      return;
    }
    try {
      // CONFIRMED (Postman collection): DELETE /api/auth/delete-account,
      // JSON body {password, confirmationText}.
      await _dio.delete<void>(
        ApiEndpoints.deleteAccount,
        data: {'password': password, 'confirmationText': confirmationText},
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
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
                  e.categoryLabel.toLowerCase() == categoryLabel.toLowerCase(),
            )
            .toList();
      }
      final start = page * pageSize;
      if (start >= rows.length) return [];
      final slice = rows.skip(start).take(pageSize).toList();
      return slice.map((e) => e.toEntity()).toList();
    }
    try {
      var rows = await _publicListingMapsForSeller(sellerId);
      if (categoryLabel != null &&
          categoryLabel.isNotEmpty &&
          categoryLabel != 'all') {
        final want = categoryLabel.toLowerCase();
        rows = [
          for (final e in rows)
            if ((_optJsonString(e, 'category') ??
                        _optJsonString(e, 'categoryLabel') ??
                        _optJsonString(e, 'categoryNameEn') ??
                        '')
                    .toLowerCase() ==
                want)
              e,
        ];
      }
      final start = page * pageSize;
      if (start >= rows.length) return const [];
      final out = <ListingEntity>[];
      for (final e in rows.skip(start).take(pageSize)) {
        try {
          out.add(ListingModel.fromJson(e).toEntity());
        } catch (_) {
          // Skip a catalog row that does not match ListingModel rather than
          // failing the whole storefront.
        }
      }
      return out;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> _publicListingMapsForSeller(
    String sellerId,
  ) async {
    if (_publicSellerId == sellerId && _publicSellerMaps != null) {
      return _publicSellerMaps!;
    }
    List<Map<String, dynamic>> maps = const [];
    try {
      maps = _listingMapsFromResponse(
        await _dio.get<dynamic>(
          ApiEndpoints.apiListings,
          queryParameters: {'page': 1, 'pageSize': 50},
          options: ApiAuthHeaders.public(),
        ),
      );
    } on DioException {
      maps = const [];
    }
    var mine = _mapsForSeller(maps, sellerId);
    if (mine.isEmpty) {
      maps = await _homeListingMaps();
      mine = _mapsForSeller(maps, sellerId);
    }
    _publicSellerId = sellerId;
    _publicSellerMaps = mine;
    return mine;
  }

  Future<List<Map<String, dynamic>>> _homeListingMaps() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.home,
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data is! Map) return const [];
      final map = Map<String, dynamic>.from(data);
      final seen = <String>{};
      final out = <Map<String, dynamic>>[];
      for (final key in ['newArrivals', 'recommendedForYou', 'hotDeals']) {
        for (final item in _listingMapsFromRaw(map[key])) {
          final id = (item['id'] ?? '').toString();
          if (id.isEmpty || !seen.add(id)) continue;
          out.add(item);
        }
      }
      return out;
    } on DioException {
      return const [];
    }
  }

  List<Map<String, dynamic>> _mapsForSeller(
    List<Map<String, dynamic>> maps,
    String sellerId,
  ) {
    final id = sellerId.trim();
    return [
      for (final e in maps)
        if (_listingSellerId(e) == id) e,
    ];
  }

  String _listingSellerId(Map<String, dynamic> json) =>
      (json['userId'] ?? json['vendorId'] ?? json['sellerId'] ?? '')
          .toString()
          .trim();

  String? _optJsonString(Map<String, dynamic> json, String key) {
    final v =
        json[key] ??
        json[key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}'];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  List<Map<String, dynamic>> _listingMapsFromResponse(
    Response<dynamic> response,
  ) => _listingMapsFromRaw(response.data);

  List<Map<String, dynamic>> _listingMapsFromRaw(dynamic data) {
    final raw = <Map<String, dynamic>>[];
    if (data is List) {
      raw.addAll(
        data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    } else if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final nested = m['items'] ?? m['data'] ?? m['results'] ?? m['listings'];
      if (nested is List) {
        raw.addAll(
          nested.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    }
    return [
      for (final item in raw)
        if (isPublicLiveListingStatus(item['status']) &&
            (item['id'] ?? '').toString().isNotEmpty)
          item,
    ];
  }
}
