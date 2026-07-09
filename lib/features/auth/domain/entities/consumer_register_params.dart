import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumer_register_params.freezed.dart';

@freezed
class ConsumerRegisterParams with _$ConsumerRegisterParams {
  const factory ConsumerRegisterParams({
    required String fullNameEn,
    required String fullNameAr,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    DateTime? dateOfBirth,
  }) = _ConsumerRegisterParams;
}
