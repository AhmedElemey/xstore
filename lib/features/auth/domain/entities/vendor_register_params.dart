import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_register_params.freezed.dart';

@freezed
class VendorRegisterParams with _$VendorRegisterParams {
  const factory VendorRegisterParams({
    required String fullNameEn,
    required String fullNameAr,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    DateTime? dateOfBirth,
    required String storeNameEn,
    required String storeNameAr,
    required String storeDescriptionEn,
    required String storeDescriptionAr,
    required int storeCategoryId,
    required int storeCityId,
    required int storeGovernmentId,
    required String whatsappNumber,
    // Local file path of the store/profile image. The live vendor-register
    // endpoint is multipart and rejects the request without it.
    required String profileImagePath,
  }) = _VendorRegisterParams;
}
