import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Role used for routing (vendor shell vs consumer shell vs courier shell).
///
/// [courier] accounts are created by the platform owner (no self-registration
/// path); they collect COD cash from buyers and hand it over to xStore.
enum UserRole {
  vendor,
  consumer,
  courier,
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
    // Store name/description are single (not bilingual) fields.
    String? fullNameEn,
    String? fullNameAr,
    int? storeCategoryId,
    int? storeCityId,
    int? storeGovernmentId,
    int? storeId,
  }) = _UserEntity;

  /// True when get-profile returned a non-null `store` object.
  bool get hasStore => storeId != null;

  bool get isVendor => role == UserRole.vendor || hasStore;

  bool get isCourier => role == UserRole.courier;

  /// Resolves the bilingual full name for the current app language, falling
  /// back to legacy [name] when the En/Ar variant is unset.
  String displayName(bool isArabic) {
    final localized = isArabic ? fullNameAr : fullNameEn;
    return (localized != null && localized.trim().isNotEmpty)
        ? localized.trim()
        : name;
  }
}

extension UserEntityNavRoleX on UserEntity? {
  UserRole get toUserRole => this?.role ?? UserRole.consumer;
}
