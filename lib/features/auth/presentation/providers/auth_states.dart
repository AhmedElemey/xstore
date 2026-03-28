import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'auth_states.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool rememberMe,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isLoading,
    String? error,
  }) = _LoginState;
}

enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong,
}

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(1) int currentStep,
    @Default(3) int totalSteps,
    UserRole? selectedRole,
    @Default('') String fullName,
    @Default('') String email,
    @Default('') String phoneNumber,
    @Default('+213') String countryCode,
    DateTime? dateOfBirth,
    @Default('') String location,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    @Default(PasswordStrength.none) PasswordStrength passwordStrength,
    @Default(false) bool agreedToTerms,
    @Default('') String storeName,
    @Default('') String storeSlug,
    @Default('') String storeCategory,
    @Default('') String storeDescription,
    String? storeLogoPath,
    @Default('') String storeCity,
    @Default('') String storeWilaya,
    @Default('') String whatsappNumber,
    @Default(false) bool isLoading,
    String? error,
    @Default({}) Map<String, String> stepErrors,
    @Default(false) bool showVendorSuccessOverlay,
  }) = _RegisterState;
}
