import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';

/// API/auth DTO. Persisted via [toJson] / [UserModel.fromJson].
@Freezed(fromJson: false, toJson: false)
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @Default('') String name,
    required String email,
    @Default('') String phoneNumber,
    String? avatarUrl,
    @Default(UserRole.consumer) UserRole role,
    @Default(false) bool isVerified,
    double? rating,
    int? totalSales,
    DateTime? joinedAt,
    String? location,
    String? storeName,
    String? storeSlug,
    String? storeCategory,
    String? storeDescription,
    String? storeLogoUrl,
    String? storeCity,
    String? storeWilaya,
    String? whatsappNumber,
    double? latitude,
    double? longitude,
    String? governorate,
    String? town,
    String? detailAddress,
    String? bio,
    DateTime? dateOfBirth,
    String? instagramHandle,
    String? facebookPage,
    String? token,
    String? refreshToken,
    @Default(false) bool isNewUser,
    String? fullNameEn,
    String? fullNameAr,
    String? storeNameEn,
    String? storeNameAr,
    String? storeDescriptionEn,
    String? storeDescriptionAr,
    int? storeCategoryId,
    int? storeCityId,
    int? storeGovernmentId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parseRole() {
      // CONFIRMED: real get-profile response sends `roleName` (capitalized,
      // e.g. "Consumer"/"Vendor"), not `role`. Checked case-insensitively
      // alongside the older `role`/`isVendor` shapes for resilience.
      final r = (json['roleName'] as String?) ?? (json['role'] as String?);
      if (r != null) {
        if (r.toLowerCase() == UserRole.vendor.name) return UserRole.vendor;
        if (r.toLowerCase() == UserRole.consumer.name) return UserRole.consumer;
      }
      final legacy = json['isVendor'] as bool? ?? false;
      return legacy ? UserRole.vendor : UserRole.consumer;
    }

    DateTime? parseDate(String? key, {String? altKey}) {
      final v = json[key] ?? (altKey != null ? json[altKey] : null);
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return UserModel(
      // CONFIRMED: `id` is a JSON number on the real backend, not a string.
      id: json['id']?.toString() ?? '',
      // Backward compat: new backend sends fullNameEn/fullNameAr, not name.
      name: (json['name'] as String?) ??
          (json['fullNameEn'] as String?) ??
          '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: parseRole(),
      // CONFIRMED: real response sends isEmailVerified/isPhoneVerified
      // alongside isVerified — isVerified is still the field to use here.
      isVerified: json['isVerified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalSales: json['totalSales'] as int?,
      // CONFIRMED: real response sends `creationDate`, not `joinedAt`.
      joinedAt: parseDate('joinedAt', altKey: 'creationDate'),
      location: json['location'] as String?,
      storeName: json['storeName'] as String?,
      storeSlug: json['storeSlug'] as String?,
      storeCategory: json['storeCategory'] as String?,
      storeDescription: json['storeDescription'] as String?,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      storeCity: json['storeCity'] as String?,
      storeWilaya: json['storeWilaya'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      governorate: json['governorate'] as String?,
      town: json['town'] as String?,
      detailAddress: json['detailAddress'] as String?,
      bio: json['bio'] as String?,
      // CONFIRMED: real response sends `birthDate`, not `dateOfBirth`.
      dateOfBirth: parseDate('dateOfBirth', altKey: 'birthDate'),
      instagramHandle: json['instagramHandle'] as String?,
      facebookPage: json['facebookPage'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
      fullNameEn: json['fullNameEn'] as String?,
      fullNameAr: json['fullNameAr'] as String?,
      storeNameEn: json['storeNameEn'] as String?,
      storeNameAr: json['storeNameAr'] as String?,
      storeDescriptionEn: json['storeDescriptionEn'] as String?,
      storeDescriptionAr: json['storeDescriptionAr'] as String?,
      storeCategoryId: json['storeCategoryId'] as int?,
      storeCityId: json['storeCityId'] as int?,
      storeGovernmentId: json['storeGovernmentId'] as int?,
    );
  }
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        role: role,
        isVerified: isVerified,
        rating: rating,
        totalSales: totalSales,
        joinedAt: joinedAt,
        location: location,
        storeName: storeName,
        storeSlug: storeSlug,
        storeCategory: storeCategory,
        storeDescription: storeDescription,
        storeLogoUrl: storeLogoUrl,
        storeCity: storeCity,
        storeWilaya: storeWilaya,
        whatsappNumber: whatsappNumber,
        latitude: latitude,
        longitude: longitude,
        governorate: governorate,
        town: town,
        detailAddress: detailAddress,
        bio: bio,
        dateOfBirth: dateOfBirth,
        instagramHandle: instagramHandle,
        facebookPage: facebookPage,
        isNewUser: isNewUser,
        fullNameEn: fullNameEn,
        fullNameAr: fullNameAr,
        storeNameEn: storeNameEn,
        storeNameAr: storeNameAr,
        storeDescriptionEn: storeDescriptionEn,
        storeDescriptionAr: storeDescriptionAr,
        storeCategoryId: storeCategoryId,
        storeCityId: storeCityId,
        storeGovernmentId: storeGovernmentId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'role': role.name,
        'isVendor': role == UserRole.vendor,
        'isVerified': isVerified,
        if (rating != null) 'rating': rating,
        if (totalSales != null) 'totalSales': totalSales,
        if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
        if (location != null) 'location': location,
        if (storeName != null) 'storeName': storeName,
        if (storeSlug != null) 'storeSlug': storeSlug,
        if (storeCategory != null) 'storeCategory': storeCategory,
        if (storeDescription != null) 'storeDescription': storeDescription,
        if (storeLogoUrl != null) 'storeLogoUrl': storeLogoUrl,
        if (storeCity != null) 'storeCity': storeCity,
        if (storeWilaya != null) 'storeWilaya': storeWilaya,
        if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (governorate != null) 'governorate': governorate,
        if (town != null) 'town': town,
        if (detailAddress != null) 'detailAddress': detailAddress,
        if (bio != null) 'bio': bio,
        if (dateOfBirth != null)
          'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (instagramHandle != null) 'instagramHandle': instagramHandle,
        if (facebookPage != null) 'facebookPage': facebookPage,
        if (token != null) 'token': token,
        if (refreshToken != null) 'refreshToken': refreshToken,
        'isNewUser': isNewUser,
        if (fullNameEn != null) 'fullNameEn': fullNameEn,
        if (fullNameAr != null) 'fullNameAr': fullNameAr,
        if (storeNameEn != null) 'storeNameEn': storeNameEn,
        if (storeNameAr != null) 'storeNameAr': storeNameAr,
        if (storeDescriptionEn != null)
          'storeDescriptionEn': storeDescriptionEn,
        if (storeDescriptionAr != null)
          'storeDescriptionAr': storeDescriptionAr,
        if (storeCategoryId != null) 'storeCategoryId': storeCategoryId,
        if (storeCityId != null) 'storeCityId': storeCityId,
        if (storeGovernmentId != null) 'storeGovernmentId': storeGovernmentId,
      };
}
