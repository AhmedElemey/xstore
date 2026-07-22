import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/social_auth_datasource.dart';
import '../../data/datasources/phone_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/consumer_register_params.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vendor_register_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_consumer_usecase.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_forgot_password_otp_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/send_email_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import '../../domain/usecases/send_phone_otp_backend_usecase.dart';
import '../../domain/usecases/verify_phone_otp_backend_usecase.dart';
import '../../domain/usecases/apple_sign_in_usecase.dart';
import '../../domain/usecases/facebook_sign_in_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/send_login_otp_usecase.dart';
import '../../domain/usecases/login_with_otp_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../notifications/presentation/providers/fcm_device_token_sync_provider.dart';
import 'auth_states.dart';
import 'guest_mode_provider.dart';

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
RegisterConsumerUseCase registerConsumerUseCase(RegisterConsumerUseCaseRef ref) {
  return RegisterConsumerUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RegisterVendorUseCase registerVendorUseCase(RegisterVendorUseCaseRef ref) {
  return RegisterVendorUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ChangePasswordUseCase changePasswordUseCase(ChangePasswordUseCaseRef ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ForgotPasswordUseCase forgotPasswordUseCase(ForgotPasswordUseCaseRef ref) {
  return ForgotPasswordUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyForgotPasswordOtpUseCase verifyForgotPasswordOtpUseCase(
  VerifyForgotPasswordOtpUseCaseRef ref,
) {
  return VerifyForgotPasswordOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RefreshTokenUseCase refreshTokenUseCase(RefreshTokenUseCaseRef ref) {
  return RefreshTokenUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SendEmailOtpUseCase sendEmailOtpUseCase(SendEmailOtpUseCaseRef ref) {
  return SendEmailOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyEmailOtpUseCase verifyEmailOtpUseCase(VerifyEmailOtpUseCaseRef ref) {
  return VerifyEmailOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SendPhoneOtpBackendUseCase sendPhoneOtpBackendUseCase(
  SendPhoneOtpBackendUseCaseRef ref,
) {
  return SendPhoneOtpBackendUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyPhoneOtpBackendUseCase verifyPhoneOtpBackendUseCase(
  VerifyPhoneOtpBackendUseCaseRef ref,
) {
  return VerifyPhoneOtpBackendUseCase(ref.watch(authRepositoryProvider));
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

@riverpod
SendLoginOtpUseCase sendLoginOtpUseCase(SendLoginOtpUseCaseRef ref) {
  return SendLoginOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LoginWithOtpUseCase loginWithOtpUseCase(LoginWithOtpUseCaseRef ref) {
  return LoginWithOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GoogleLoginUseCase googleLoginUseCase(GoogleLoginUseCaseRef ref) {
  return GoogleLoginUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  // Notifier fields survive ref.invalidate (build() re-runs on the same
  // instance), so this stays true across rebuilds triggered by saveProfile
  // etc. — those already refresh the profile explicitly; only the cold-start
  // restore should prefetch.
  var _restoredOnce = false;

  @override
  Future<UserEntity?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.restoreSession();
    final firstRestore = !_restoredOnce;
    _restoredOnce = true;
    if (firstRestore) {
      ref.read(fcmDeviceTokenSyncProvider);
    }
    return result.fold((_) => null, (user) {
      // build() hasn't returned yet, so authProvider still reads as Loading —
      // pass the user in; a plain prefetch here would see null and no-op.
      if (firstRestore) {
        prefetchProfileData(ref, user: user);
        syncFcmDeviceTokenWithBackend(ref, user: user);
      }
      return user;
    });
  }

  Future<void> logout() async {
    unregisterFcmDeviceTokenOnLogout(ref);
    await ref.read(logoutUseCaseProvider).call();
    resetProfileData(ref);
    ref.invalidateSelf();
  }

  Future<void> setUser(UserEntity user) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).persistSessionUser(user);
    ref.read(guestModeProvider.notifier).disable();
    state = result.fold(
      (_) => AsyncData(user),
      (_) => AsyncData(user),
    );
    syncFcmDeviceTokenWithBackend(ref);
    prefetchProfileData(ref);
  }

  /// Session already persisted (e.g. login/register API) — update auth without
  /// reloading from storage, which would recreate [GoRouter] mid-navigation.
  void adoptSession(UserEntity user) {
    ref.read(guestModeProvider.notifier).disable();
    state = AsyncData(user);
    syncFcmDeviceTokenWithBackend(ref);
    prefetchProfileData(ref);
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  // Set when this autoDispose notifier is torn down (screen popped) so
  // in-flight requests don't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  @override
  LoginState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const LoginState();
  }

  void updatePhone(String v) => state = state.copyWith(phone: v, error: null);

  void updatePassword(String v) => state = state.copyWith(password: v, error: null);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);

  void toggleRememberMe() => state = state.copyWith(rememberMe: !state.rememberMe);

  void setRememberMe(bool value) => state = state.copyWith(rememberMe: value);

  void clearError() => state = state.copyWith(error: null);

  bool validate(AppLocalizations l10n) {
    final phoneErr = Validators.egyptPhone(l10n, state.phone);
    if (phoneErr != null) {
      state = state.copyWith(error: phoneErr);
      return false;
    }
    final passErr = Validators.loginPassword(l10n, state.password);
    if (passErr != null) {
      state = state.copyWith(error: passErr);
      return false;
    }
    return true;
  }

  Future<void> login(AppLocalizations l10n) async {
    if (!validate(l10n)) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(loginUseCaseProvider).call(
          LoginParams(
            // Backend `emailOrPhone` field; the app authenticates by phone.
            emailOrPhone: AppValidators.normalizeEgyptLocal(state.phone),
            password: state.password,
            rememberMe: state.rememberMe,
          ),
        );
    if (_disposed) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (user) {
        state = state.copyWith(isLoading: false, error: null);
        ref.read(authProvider.notifier).adoptSession(user);
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
  // See LoginNotifier._disposed — same guard for in-flight async writes.
  var _disposed = false;

  @override
  RegisterState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const RegisterState();
  }

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
    String? fullNameAr,
    String? email,
    String? phoneNumber,
    String? countryCode,
    DateTime? dateOfBirth,
    String? location,
    String? storeName,
    String? storeNameAr,
    String? storeCategory,
    String? storeDescription,
    String? storeDescriptionAr,
    String? storeCity,
    String? storeWilaya,
    int? storeCategoryId,
    int? storeCityId,
    int? storeGovernmentId,
    String? whatsappNumber,
  }) {
    var next = state;
    if (fullName != null) next = next.copyWith(fullName: fullName);
    if (fullNameAr != null) next = next.copyWith(fullNameAr: fullNameAr);
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
    if (storeNameAr != null) next = next.copyWith(storeNameAr: storeNameAr);
    if (storeCategory != null) next = next.copyWith(storeCategory: storeCategory);
    if (storeDescription != null) {
      final t = storeDescription.length > 300
          ? storeDescription.substring(0, 300)
          : storeDescription;
      next = next.copyWith(storeDescription: t);
    }
    if (storeDescriptionAr != null) {
      final t = storeDescriptionAr.length > 300
          ? storeDescriptionAr.substring(0, 300)
          : storeDescriptionAr;
      next = next.copyWith(storeDescriptionAr: t);
    }
    if (storeCity != null) next = next.copyWith(storeCity: storeCity);
    if (storeWilaya != null) next = next.copyWith(storeWilaya: storeWilaya);
    if (storeCategoryId != null) {
      next = next.copyWith(storeCategoryId: storeCategoryId);
    }
    if (storeCityId != null) next = next.copyWith(storeCityId: storeCityId);
    if (storeGovernmentId != null) {
      next = next.copyWith(storeGovernmentId: storeGovernmentId);
    }
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
    if (_disposed) return;
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

        final fnAr = Validators.nonEmptyLine(
          l10n,
          state.fullNameAr,
          (l) => l.validationFullNameArRequired,
        );
        if (fnAr != null) errors['fullNameAr'] = fnAr;

        // Email is now REQUIRED by the backend for both consumer and vendor
        // register (an empty/missing email 400s server-side).
        if (state.email.trim().isEmpty) {
          errors['email'] = l10n.validationEmailRequired;
        } else {
          final em = Validators.registerEmail(l10n, state.email);
          if (em != null) errors['email'] = em;
        }

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

        final snAr = Validators.nonEmptyLine(
          l10n,
          state.storeNameAr,
          (l) => l.validationStoreNameArRequired,
        );
        if (snAr != null) errors['storeNameAr'] = snAr;

        if (state.storeCategoryId == null) {
          errors['storeCategory'] = l10n.validationStoreCategoryRequired;
        }
        final desc = state.storeDescription.trim();
        if (desc.length < 3) {
          errors['storeDescription'] = l10n.validationStoreDescriptionShort;
        } else if (desc.length > 300) {
          errors['storeDescription'] = l10n.validationStoreDescriptionMax;
        }
        final descAr = state.storeDescriptionAr.trim();
        if (descAr.length < 3) {
          errors['storeDescriptionAr'] = l10n.validationStoreDescriptionArShort;
        } else if (descAr.length > 300) {
          errors['storeDescriptionAr'] = l10n.validationStoreDescriptionMax;
        }
        if (state.storeCityId == null || state.storeGovernmentId == null) {
          errors['storeLocation'] = l10n.validationStoreCityWilayaRequired;
        }
        // The vendor-register endpoint requires a store image (multipart).
        if (state.storeLogoPath == null || state.storeLogoPath!.trim().isEmpty) {
          errors['storeLogo'] = l10n.validationStoreLogoRequired;
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
    state = state.copyWith(isLoading: true, error: null, stepErrors: {});
    final role = state.selectedRole ?? UserRole.consumer;
    final result = role == UserRole.vendor
        ? await ref.read(registerVendorUseCaseProvider).call(
              VendorRegisterParams(
                fullNameEn: state.fullName.trim(),
                fullNameAr: state.fullNameAr.trim(),
                email: state.email.trim(),
                phoneNumber: state.phoneNumber,
                password: state.password,
                confirmPassword: state.confirmPassword,
                dateOfBirth: state.dateOfBirth,
                storeNameEn: state.storeName,
                storeNameAr: state.storeNameAr,
                storeDescriptionEn: state.storeDescription,
                storeDescriptionAr: state.storeDescriptionAr,
                storeCategoryId: state.storeCategoryId!,
                storeCityId: state.storeCityId!,
                storeGovernmentId: state.storeGovernmentId!,
                whatsappNumber: state.whatsappNumber,
                profileImagePath: state.storeLogoPath ?? '',
              ),
            )
        : await ref.read(registerConsumerUseCaseProvider).call(
              ConsumerRegisterParams(
                fullNameEn: state.fullName.trim(),
                fullNameAr: state.fullNameAr.trim(),
                email: state.email.trim(),
                phoneNumber: state.phoneNumber,
                password: state.password,
                confirmPassword: state.confirmPassword,
                dateOfBirth: state.dateOfBirth,
              ),
            );
    if (_disposed) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (user) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          showVendorSuccessOverlay: role == UserRole.vendor,
        );
        ref.read(authProvider.notifier).adoptSession(user);
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
