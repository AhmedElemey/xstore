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
    double? latitude,
    double? longitude,
    String? governorate,
    String? town,
    String? detailAddress,
    String? bio,
    DateTime? dateOfBirth,
    String? instagramHandle,
    String? facebookPage,
    @Default(false) bool isNewUser,
    // --- Bilingual/backend-ID fields (Phase 1 backend integration) ---
    // Additive: legacy fields above are kept so unrelated screens keep
    // working. [name] is populated from [fullNameEn] on login/register for
    // backward compatibility — see UserModel.fromJson.
    String? fullNameEn,
    String? fullNameAr,
    String? storeNameEn,
    String? storeNameAr,
    String? storeDescriptionEn,
    String? storeDescriptionAr,
    int? storeCategoryId,
    int? storeCityId,
    int? storeGovernmentId,
  }) = _UserEntity;

  bool get isVendor => role == UserRole.vendor;

  /// Resolves the bilingual full name for the current app language, falling
  /// back to legacy [name] when the En/Ar variant is unset.
  String displayName(bool isArabic) {
    final localized = isArabic ? fullNameAr : fullNameEn;
    return (localized != null && localized.trim().isNotEmpty)
        ? localized.trim()
        : name;
  }

  /// Same resolution rules as [displayName], for vendor store names.
  String displayStoreName(bool isArabic) {
    final localized = isArabic ? storeNameAr : storeNameEn;
    if (localized != null && localized.trim().isNotEmpty) {
      return localized.trim();
    }
    final legacy = storeName?.trim();
    return (legacy != null && legacy.isNotEmpty) ? legacy : '';
  }
}

extension UserEntityNavRoleX on UserEntity? {
  UserRole get toUserRole => this?.role ?? UserRole.consumer;
}
