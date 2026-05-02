import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
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

  bool validate(AppLocalizations l10n) {
    final id = state.email.trim();
    final pass = state.password;
    final idErr = Validators.loginEmailOrPhone(l10n, id);
    if (idErr != null) {
      state = state.copyWith(error: idErr);
      return false;
    }
    final passErr = Validators.loginPassword(l10n, pass);
    if (passErr != null) {
      state = state.copyWith(error: passErr);
      return false;
    }
    return true;
  }

  Future<void> login(AppLocalizations l10n) async {
    if (!validate(l10n)) return;
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

  Map<String, String> validateStep(int step, AppLocalizations l10n) {
    final errors = <String, String>{};
    switch (step) {
      case 1:
        if (state.selectedRole == null) {
          errors['role'] = l10n.validationRegisterRoleRequired;
        }
        return errors;
      case 2:
        final fn = Validators.personFullName(l10n, state.fullName);
        if (fn != null) errors['fullName'] = fn;

        final em = Validators.registerEmail(l10n, state.email);
        if (em != null) errors['email'] = em;

        final ph = Validators.registerPhoneEgypt(
          l10n,
          rawInput: state.phoneNumber,
        );
        if (ph != null) errors['phone'] = ph;

        final loc = Validators.nonEmptyLine(
          l10n,
          state.location,
          (l) => l.validationCityRequired,
        );
        if (loc != null) errors['location'] = loc;

        if (state.dateOfBirth != null) {
          final age = DateTime.now().difference(state.dateOfBirth!).inDays ~/ 365;
          if (age < 18) {
            errors['dob'] = l10n.validationAgeMinimum18;
          }
        }
        return errors;
      case 3:
        final pw = Validators.registerPassword(l10n, state.password);
        if (pw != null) errors['password'] = pw;

        final match = Validators.confirmPasswordMatches(
          l10n,
          state.password,
          state.confirmPassword,
        );
        if (match != null) errors['confirm'] = match;

        if (!state.agreedToTerms) {
          errors['terms'] = l10n.validationTermsRequired;
        }
        return errors;
      case 4:
        if (state.selectedRole != UserRole.vendor) {
          return errors;
        }
        final sn = Validators.nonEmptyLine(
          l10n,
          state.storeName,
          (l) => l.validationStoreNameRequired,
        );
        if (sn != null) errors['storeName'] = sn;

        if (state.storeCategory.isEmpty) {
          errors['storeCategory'] = l10n.validationStoreCategoryRequired;
        }
        final desc = state.storeDescription.trim();
        if (desc.length < 3) {
          errors['storeDescription'] = l10n.validationStoreDescriptionShort;
        } else if (desc.length > 300) {
          errors['storeDescription'] = l10n.validationStoreDescriptionMax;
        }
        if (state.storeCity.trim().isEmpty || state.storeWilaya.trim().isEmpty) {
          errors['storeLocation'] = l10n.validationStoreCityWilayaRequired;
        }
        return errors;
      default:
        return errors;
    }
  }

  bool nextStep(AppLocalizations l10n) {
    final errors = validateStep(state.currentStep, l10n);
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
  Future<void> submitFromCurrentStep(AppLocalizations l10n) async {
    final role = state.selectedRole ?? UserRole.consumer;
    if (role == UserRole.consumer && state.currentStep == 3) {
      final e3 = validateStep(3, l10n);
      if (e3.isNotEmpty) {
        state = state.copyWith(stepErrors: e3);
        return;
      }
      await _executeRegister();
      return;
    }
    if (role == UserRole.vendor && state.currentStep == 4) {
      final all = {...validateStep(3, l10n), ...validateStep(4, l10n)};
      if (all.isNotEmpty) {
        state = state.copyWith(stepErrors: all);
        return;
      }
      await _executeRegister();
    }
  }
}
