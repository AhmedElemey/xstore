import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/social_auth_datasource.dart';
import '../../data/datasources/phone_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/apple_sign_in_usecase.dart';
import '../../domain/usecases/facebook_sign_in_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_states.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    social: ref.watch(socialAuthDatasourceProvider),
    phone: ref.watch(phoneAuthDatasourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}

@Riverpod(keepAlive: true)
SocialAuthDatasource socialAuthDatasource(SocialAuthDatasourceRef ref) {
  return SocialAuthDatasourceImpl();
}

@Riverpod(keepAlive: true)
PhoneAuthDatasource phoneAuthDatasource(PhoneAuthDatasourceRef ref) {
  return PhoneAuthDatasourceImpl();
}

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GoogleSignInUseCase googleSignInUseCase(GoogleSignInUseCaseRef ref) {
  return GoogleSignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
AppleSignInUseCase appleSignInUseCase(AppleSignInUseCaseRef ref) {
  return AppleSignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
FacebookSignInUseCase facebookSignInUseCase(FacebookSignInUseCaseRef ref) {
  return FacebookSignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SendOtpUseCase sendOtpUseCase(SendOtpUseCaseRef ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyOtpUseCase verifyOtpUseCase(VerifyOtpUseCaseRef ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<UserEntity?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.restoreSession();
    return result.fold((_) => null, (user) => user);
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    ref.invalidateSelf();
  }

  Future<void> setUser(UserEntity user) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).persistSessionUser(user);
    state = result.fold(
      (_) => AsyncData(user),
      (_) => AsyncData(user),
    );
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginState();

  void updateEmail(String v) => state = state.copyWith(email: v, error: null);

  void updatePassword(String v) => state = state.copyWith(password: v, error: null);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);

  void toggleRememberMe() => state = state.copyWith(rememberMe: !state.rememberMe);

  void setRememberMe(bool value) => state = state.copyWith(rememberMe: value);

  void clearError() => state = state.copyWith(error: null);

  bool validate() {
    final id = state.email.trim();
    final pass = state.password;
    if (id.isEmpty) {
      state = state.copyWith(error: 'Email or phone is required');
      return false;
    }
    if (!_isValidEmailOrPhone(id)) {
      state = state.copyWith(error: 'Enter a valid email or 10+ digit phone');
      return false;
    }
    if (pass.isEmpty) {
      state = state.copyWith(error: 'Password is required');
      return false;
    }
    if (pass.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!validate()) return;
    state = state.copyWith(isLoading: true, error: null);
    final params = LoginParams(
      emailOrPhone: state.email.trim(),
      password: state.password,
      rememberMe: state.rememberMe,
    );
    final result = await ref.read(loginUseCaseProvider).call(params);
    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.toString());
      },
      (_) async {
        if (state.rememberMe) {
          final prefs = await ref.read(sharedPreferencesProvider.future);
          await prefs.setString(PrefsKeys.rememberedEmail, state.email.trim());
        } else {
          final prefs = await ref.read(sharedPreferencesProvider.future);
          await prefs.remove(PrefsKeys.rememberedEmail);
        }
        state = state.copyWith(isLoading: false, error: null);
        ref.invalidate(authProvider);
      },
    );
  }
}

bool _isValidEmailOrPhone(String v) {
  final t = v.trim();
  if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t)) return true;
  final digits = t.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 10;
}

String slugifyStoreName(String input) {
  final slug = input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  return slug.isEmpty ? 'store' : slug;
}

PasswordStrength computePasswordStrengthFor(String p) {
  if (p.isEmpty) return PasswordStrength.none;
  final hasUpper = RegExp(r'[A-Z]').hasMatch(p);
  final hasNum = RegExp(r'[0-9]').hasMatch(p);
  final hasSym = RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;`~']''').hasMatch(p);
  if (p.length >= 8 && hasUpper && hasNum && hasSym) {
    return PasswordStrength.strong;
  }
  if (p.length >= 8 && (hasNum || hasSym)) {
    return PasswordStrength.good;
  }
  if (p.length >= 6) {
    return PasswordStrength.fair;
  }
  return PasswordStrength.weak;
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  RegisterState build() => const RegisterState();

  void reset() => state = const RegisterState();

  void updateRole(UserRole role) {
    state = state.copyWith(
      selectedRole: role,
      totalSteps: role == UserRole.vendor ? 4 : 3,
      stepErrors: {},
      error: null,
    );
  }

  void updatePasswordFields(String password) {
    state = state.copyWith(
      password: password,
      passwordStrength: computePasswordStrengthFor(password),
      stepErrors: {},
      error: null,
    );
  }

  void updateConfirmPassword(String v) =>
      state = state.copyWith(confirmPassword: v, stepErrors: {}, error: null);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);

  void toggleConfirmPasswordVisibility() => state =
      state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);

  void toggleAgreedToTerms() =>
      state = state.copyWith(agreedToTerms: !state.agreedToTerms, stepErrors: {});

  void updateField({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? countryCode,
    DateTime? dateOfBirth,
    String? location,
    String? storeName,
    String? storeCategory,
    String? storeDescription,
    String? storeCity,
    String? storeWilaya,
    String? whatsappNumber,
  }) {
    var next = state;
    if (fullName != null) next = next.copyWith(fullName: fullName);
    if (email != null) next = next.copyWith(email: email);
    if (phoneNumber != null) next = next.copyWith(phoneNumber: phoneNumber);
    if (countryCode != null) next = next.copyWith(countryCode: countryCode);
    if (dateOfBirth != null) next = next.copyWith(dateOfBirth: dateOfBirth);
    if (location != null) next = next.copyWith(location: location);
    if (storeName != null) {
      next = next.copyWith(
        storeName: storeName,
        storeSlug: slugifyStoreName(storeName),
      );
    }
    if (storeCategory != null) next = next.copyWith(storeCategory: storeCategory);
    if (storeDescription != null) {
      final t = storeDescription.length > 300
          ? storeDescription.substring(0, 300)
          : storeDescription;
      next = next.copyWith(storeDescription: t);
    }
    if (storeCity != null) next = next.copyWith(storeCity: storeCity);
    if (storeWilaya != null) next = next.copyWith(storeWilaya: storeWilaya);
    if (whatsappNumber != null) next = next.copyWith(whatsappNumber: whatsappNumber);
    state = next.copyWith(stepErrors: {}, error: null);
  }

  void clearStepErrors() => state = state.copyWith(stepErrors: {});

  Future<void> pickStoreLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file != null) {
      state = state.copyWith(storeLogoPath: file.path, stepErrors: {});
    }
  }

  Map<String, String> validateStep(int step) {
    final errors = <String, String>{};
    switch (step) {
      case 1:
        if (state.selectedRole == null) {
          errors['role'] = 'Select how you want to use xStore';
        }
        return errors;
      case 2:
        if (state.fullName.trim().length < 3 ||
            !RegExp(r'^[a-zA-Z\s]+$').hasMatch(state.fullName.trim())) {
          errors['fullName'] = 'Enter your full name (letters only, min 3 chars)';
        }
        if (!_isValidEmail(state.email)) {
          errors['email'] = 'Enter a valid email';
        }
        if (!_isValidPhone(state.phoneNumber)) {
          errors['phone'] = 'Enter a valid phone number';
        }
        if (state.location.trim().isEmpty) {
          errors['location'] = 'City is required';
        }
        if (state.dateOfBirth != null) {
          final age = DateTime.now().difference(state.dateOfBirth!).inDays ~/ 365;
          if (age < 18) {
            errors['dob'] = 'You must be at least 18 years old';
          }
        }
        return errors;
      case 3:
        if (state.password.length < 8) {
          errors['password'] = 'Password must be at least 8 characters';
        }
        if (state.password != state.confirmPassword) {
          errors['confirm'] = 'Passwords do not match';
        }
        if (!state.agreedToTerms) {
          errors['terms'] = 'Please accept the terms to continue';
        }
        return errors;
      case 4:
        if (state.selectedRole != UserRole.vendor) {
          return errors;
        }
        if (state.storeName.trim().isEmpty) {
          errors['storeName'] = 'Store name is required';
        }
        if (state.storeCategory.isEmpty) {
          errors['storeCategory'] = 'Pick a category';
        }
        final desc = state.storeDescription.trim();
        if (desc.length < 3) {
          errors['storeDescription'] = 'Describe your store';
        } else if (desc.length > 300) {
          errors['storeDescription'] = 'Max 300 characters';
        }
        if (state.storeCity.trim().isEmpty || state.storeWilaya.trim().isEmpty) {
          errors['storeLocation'] = 'City and wilaya are required';
        }
        return errors;
      default:
        return errors;
    }
  }

  bool nextStep() {
    final errors = validateStep(state.currentStep);
    if (errors.isNotEmpty) {
      state = state.copyWith(stepErrors: errors);
      return false;
    }
    state = state.copyWith(stepErrors: {}, error: null);
    if (state.currentStep < state.totalSteps) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
    return true;
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        stepErrors: {},
        error: null,
      );
    }
  }

  void dismissVendorSuccessOverlay() {
    state = state.copyWith(showVendorSuccessOverlay: false);
  }

  Future<void> _executeRegister() async {
    final role = state.selectedRole ?? UserRole.consumer;
    final params = RegisterParams(
      role: role,
      fullName: state.fullName.trim(),
      email: state.email.trim(),
      phoneNumber: state.phoneNumber.replaceAll(RegExp(r'\D'), ''),
      countryCode: '+20',
      dateOfBirth: state.dateOfBirth,
      location: state.location.trim(),
      password: state.password,
      storeName: role == UserRole.vendor ? state.storeName.trim() : null,
      storeCategory: role == UserRole.vendor ? state.storeCategory : null,
      storeDescription: role == UserRole.vendor ? state.storeDescription.trim() : null,
      storeLogoPath: state.storeLogoPath,
      storeCity: role == UserRole.vendor ? state.storeCity.trim() : null,
      storeWilaya: role == UserRole.vendor ? state.storeWilaya.trim() : null,
      whatsappNumber: state.whatsappNumber.trim().isEmpty
          ? null
          : state.whatsappNumber.trim(),
    );

    state = state.copyWith(isLoading: true, error: null, stepErrors: {});
    final result = await ref.read(registerUseCaseProvider).call(params);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.toString());
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          showVendorSuccessOverlay: role == UserRole.vendor,
        );
        ref.invalidate(authProvider);
      },
    );
  }

  /// Consumer: call from step 3. Vendor: call from step 4.
  Future<void> submitFromCurrentStep() async {
    final role = state.selectedRole ?? UserRole.consumer;
    if (role == UserRole.consumer && state.currentStep == 3) {
      final e3 = validateStep(3);
      if (e3.isNotEmpty) {
        state = state.copyWith(stepErrors: e3);
        return;
      }
      await _executeRegister();
      return;
    }
    if (role == UserRole.vendor && state.currentStep == 4) {
      final all = {...validateStep(3), ...validateStep(4)};
      if (all.isNotEmpty) {
        state = state.copyWith(stepErrors: all);
        return;
      }
      await _executeRegister();
    }
  }
}

bool _isValidEmail(String v) {
  final t = v.trim();
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t);
}

bool _isValidPhone(String v) {
  final digits = v.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^01[0125]\d{8}$').hasMatch(digits);
}
