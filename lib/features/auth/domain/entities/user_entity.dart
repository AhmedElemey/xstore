import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Role used for routing (vendor shell vs consumer shell).
enum UserRole {
  vendor,
  consumer,
}

@freezed
class UserEntity with _$UserEntity {
  const UserEntity._();

  const factory UserEntity({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? avatarUrl,
    @Default(UserRole.consumer) UserRole role,
    @Default(false) bool isVerified,
    double? rating,
    int? totalSales,
    DateTime? joinedAt,
    String? location,
    // Vendor profile
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
    @Default(false) bool isNewUser,
  }) = _UserEntity;

  bool get isVendor => role == UserRole.vendor;
}

extension UserEntityNavRoleX on UserEntity? {
  UserRole get toUserRole => this?.role ?? UserRole.consumer;
}
