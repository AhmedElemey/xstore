import 'package:dio/dio.dart';

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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

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

  @override
  Future<ProfileModel> getVendorStoreProfile(String sellerId) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(Duration.zero);
      if (sellerId != mockVendorUser.id && sellerId != 'vendor_001') {
        throw const ServerException('Store not found');
      }
      final user = _mergeVendorMock(mockVendorUser);
      return ProfileModel(
        user: UserModel(
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
          bio: user.bio,
          dateOfBirth: user.dateOfBirth,
          instagramHandle: user.instagramHandle,
          facebookPage: user.facebookPage,
          token: null,
        ),
        storeViewCount: 2400,
        storeSaveCount: 89,
        storeActiveListings: 18,
        responseRatePercent: 89,
      );
    }
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('${ApiEndpoints.users}/$sellerId/store');
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
          user: UserModel(
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
            bio: user.bio,
            dateOfBirth: user.dateOfBirth,
            instagramHandle: user.instagramHandle,
            facebookPage: user.facebookPage,
            token: null,
          ),
          storeViewCount: 2400,
          storeSaveCount: 89,
          storeActiveListings: 18,
          responseRatePercent: 89,
        );
      }
      final user = _mergeConsumerMock(sessionUser);
      return ProfileModel(
        user: UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          avatarUrl: user.avatarUrl,
          role: user.role,
          isVerified: user.isVerified,
          joinedAt: user.joinedAt,
          location: user.location,
          bio: user.bio,
          dateOfBirth: user.dateOfBirth,
          instagramHandle: user.instagramHandle,
          facebookPage: user.facebookPage,
          token: null,
        ),
        ordersCount: 12,
        wishlistCount: 5,
        savedAmountDzd: 23000,
      );
    }
    try {
      // GET /api/auth/get-profile — identifies the user via the auth token,
      // not sessionUser.id. Response is the raw user object directly (not
      // wrapped in {"user": ...} like the old /users/{id} shape).
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.getProfile,
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty profile');
      final user = UserModel.fromJson(data);
      // ASSUMPTION: get-profile returns identity fields only — no confirmed
      // backend source yet for orders/wishlist/store stats. Default to 0
      // until a real source exists (Phase 2, once listings/orders land).
      return ProfileModel(user: user);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> updateProfile(UserEntity updated) async {
    if (MockConfig.useMock) {
      final model = await MockConfig.simulate(
        UserModel(
          id: updated.id,
          name: updated.name,
          email: updated.email,
          phoneNumber: updated.phoneNumber,
          avatarUrl: updated.avatarUrl,
          role: updated.role,
          isVerified: updated.isVerified,
          rating: updated.rating,
          totalSales: updated.totalSales,
          joinedAt: updated.joinedAt,
          location: updated.location,
          storeName: updated.storeName,
          storeSlug: updated.storeSlug,
          storeCategory: updated.storeCategory,
          storeDescription: updated.storeDescription,
          storeLogoUrl: updated.storeLogoUrl,
          storeCity: updated.storeCity,
          storeWilaya: updated.storeWilaya,
          whatsappNumber: updated.whatsappNumber,
          bio: updated.bio,
          dateOfBirth: updated.dateOfBirth,
          instagramHandle: updated.instagramHandle,
          facebookPage: updated.facebookPage,
          token: null,
          fullNameEn: updated.fullNameEn,
          fullNameAr: updated.fullNameAr,
          storeNameEn: updated.storeNameEn,
          storeNameAr: updated.storeNameAr,
          storeDescriptionEn: updated.storeDescriptionEn,
          storeDescriptionAr: updated.storeDescriptionAr,
          storeCategoryId: updated.storeCategoryId,
          storeCityId: updated.storeCityId,
          storeGovernmentId: updated.storeGovernmentId,
        ),
      );
      return model;
    }
    try {
      // PUT /api/auth/update-profile — key names per the API spec, which
      // differ from this app's internal field names in a couple of spots
      // (whatsAppNumber capital-A, instagramPage vs instagramHandle).
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.updateProfile,
        data: {
          'fullNameEn': updated.fullNameEn ?? updated.name,
          'fullNameAr': updated.fullNameAr ?? updated.name,
          'email': updated.email,
          'phoneNumber': updated.phoneNumber,
          if (updated.avatarUrl != null) 'avatarUrl': updated.avatarUrl,
          if (updated.storeNameEn != null) 'storeNameEn': updated.storeNameEn,
          if (updated.storeNameAr != null) 'storeNameAr': updated.storeNameAr,
          if (updated.storeDescriptionEn != null)
            'storeDescriptionEn': updated.storeDescriptionEn,
          if (updated.storeDescriptionAr != null)
            'storeDescriptionAr': updated.storeDescriptionAr,
          if (updated.whatsappNumber != null)
            'whatsAppNumber': updated.whatsappNumber,
          if (updated.instagramHandle != null)
            'instagramPage': updated.instagramHandle,
          if (updated.facebookPage != null)
            'facebookPage': updated.facebookPage,
        },
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return UserModel.fromJson(data);
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
      // Real upload would use multipart; placeholder URL for scaffold.
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
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.users}/$sellerId/listings',
        queryParameters: {
          if (categoryLabel != null) 'category': categoryLabel,
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = response.data?['items'] as List<dynamic>? ?? [];
      return list
          .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e as Map)).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
