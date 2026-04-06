import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_entity.dart';

part 'register_params.freezed.dart';

@freezed
class RegisterParams with _$RegisterParams {
  const factory RegisterParams({
    required UserRole role,
    required String fullName,
    required String email,
    required String phoneNumber,
    @Default('+20') String countryCode,
    DateTime? dateOfBirth,
    required String location,
    required String password,
    // Vendor only
    String? storeName,
    String? storeCategory,
    String? storeDescription,
    String? storeLogoPath,
    String? storeCity,
    String? storeWilaya,
    String? whatsappNumber,
  }) = _RegisterParams;
}
