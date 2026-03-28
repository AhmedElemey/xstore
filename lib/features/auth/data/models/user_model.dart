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
    String? bio,
    DateTime? dateOfBirth,
    String? instagramHandle,
    String? facebookPage,
    String? token,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parseRole() {
      final r = json['role'] as String?;
      if (r == UserRole.vendor.name) return UserRole.vendor;
      if (r == UserRole.consumer.name) return UserRole.consumer;
      final legacy = json['isVendor'] as bool? ?? false;
      return legacy ? UserRole.vendor : UserRole.consumer;
    }

    DateTime? parseDate(String? key) {
      final v = json[key];
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: parseRole(),
      isVerified: json['isVerified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalSales: json['totalSales'] as int?,
      joinedAt: parseDate('joinedAt'),
      location: json['location'] as String?,
      storeName: json['storeName'] as String?,
      storeSlug: json['storeSlug'] as String?,
      storeCategory: json['storeCategory'] as String?,
      storeDescription: json['storeDescription'] as String?,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      storeCity: json['storeCity'] as String?,
      storeWilaya: json['storeWilaya'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: parseDate('dateOfBirth'),
      instagramHandle: json['instagramHandle'] as String?,
      facebookPage: json['facebookPage'] as String?,
      token: json['token'] as String?,
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
        bio: bio,
        dateOfBirth: dateOfBirth,
        instagramHandle: instagramHandle,
        facebookPage: facebookPage,
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
        if (bio != null) 'bio': bio,
        if (dateOfBirth != null)
          'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (instagramHandle != null) 'instagramHandle': instagramHandle,
        if (facebookPage != null) 'facebookPage': facebookPage,
        if (token != null) 'token': token,
      };
}
