import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_request.freezed.dart';

/// Mirrors backend `UpdateProfileRequest` for PUT `/api/auth/update-profile`.
///
/// Email and phone are intentionally absent — the backend contract marks them
/// commented-out. [userImagePath] / [storeImagePath] map to `UserImage` /
/// `StoreImage` multipart fields when set.
@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? fullNameEn,
    String? fullNameAr,
    String? userImageUrl,
    String? storeImageUrl,
    String? storeNameEn,
    String? storeNameAr,
    String? storeDescriptionEn,
    String? storeDescriptionAr,
    String? whatsAppNumber,
    String? instagramPage,
    String? facebookPage,
    String? detailedAddressByGoogleMaps,
    String? detailedAddressByUser,
    String? cityByGoogleMaps,
    String? governmentByGoogleMaps,
    String? userImagePath,
    String? storeImagePath,
    double? lat,
    double? lng,
    int? storeCategoryId,
    int? cityId,
    int? governmentId,
    DateTime? birthDate,
  }) = _UpdateProfileRequest;
}
