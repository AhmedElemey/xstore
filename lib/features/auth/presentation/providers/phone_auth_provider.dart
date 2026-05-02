import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/send_otp_params.dart';
import '../../domain/entities/verify_otp_params.dart';
import 'auth_provider.dart';

class PhoneAuthState {
  const PhoneAuthState({
    this.phoneNumber = '',
    this.phoneError,
    this.verificationId,
    this.otpCode = '',
    this.otpError,
    this.expiresAt,
    this.resendToken,
    this.resendCooldown = 0,
    this.canResend = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isNewUser = false,
  });

  final String phoneNumber;
  final String? phoneError;
  final String? verificationId;
  final String otpCode;
  final String? otpError;
  final DateTime? expiresAt;
  final int? resendToken;
  final int resendCooldown;
  final bool canResend;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isNewUser;

  PhoneAuthState copyWith({
    String? phoneNumber,
    String? phoneError,
    bool clearPhoneError = false,
    String? verificationId,
    String? otpCode,
    String? otpError,
    bool clearOtpError = false,
    DateTime? expiresAt,
    int? resendToken,
    int? resendCooldown,
    bool? canResend,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isNewUser,
  }) {
    return PhoneAuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      verificationId: verificationId ?? this.verificationId,
      otpCode: otpCode ?? this.otpCode,
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      expiresAt: expiresAt ?? this.expiresAt,
      resendToken: resendToken ?? this.resendToken,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      canResend: canResend ?? this.canResend,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  PhoneAuthNotifier(this.ref) : super(const PhoneAuthState());

  final Ref ref;
  Timer? _timer;

  void updatePhone(String value, AppLocalizations l10n) {
    final normalized = AppValidators.normalizeEgyptLocal(value);
    final err = normalized.isEmpty ? null : Validators.egyptPhone(l10n, normalized);
    state = state.copyWith(
      phoneNumber: normalized,
      phoneError: err,
      clearPhoneError: err == null,
      clearOtpError: true,
    );
  }

  Future<bool> sendOtp(AppLocalizations l10n) async {
    final err = Validators.egyptPhone(l10n, state.phoneNumber);
    if (err != null) {
      state = state.copyWith(phoneError: err, isSendingOtp: false);
      return false;
    }
    state = state.copyWith(isSendingOtp: true, clearPhoneError: true);
    final params = SendOtpParams(
      phoneNumber: state.phoneNumber,
      e164Number: AppValidators.toE164Egypt(state.phoneNumber),
    );
    final result = await ref.read(sendOtpUseCaseProvider).call(params);
    return result.fold((failure) {
      state = state.copyWith(
        isSendingOtp: false,
        phoneError: failure.toString(),
      );
      return false;
    }, (ok) {
      state = state.copyWith(
        isSendingOtp: false,
        verificationId: ok.verificationId,
        resendToken: ok.resendToken,
        expiresAt: ok.expiresAt,
        resendCooldown: 60,
        canResend: false,
        clearPhoneError: true,
      );
      _startResendCooldown();
      return true;
    });
  }

  void updateOtp(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(otpCode: digits, clearOtpError: true);
  }

  Future<bool> verifyOtp() async {
    if (state.verificationId == null || state.otpCode.length != 6) return false;
    state = state.copyWith(isVerifyingOtp: true, clearOtpError: true);
    final result = await ref.read(verifyOtpUseCaseProvider).call(
          VerifyOtpParams(
            verificationId: state.verificationId!,
            otpCode: state.otpCode,
            phoneNumber: state.phoneNumber,
          ),
        );
    return result.fold((failure) {
      state = state.copyWith(
        isVerifyingOtp: false,
        otpError: failure.toString(),
      );
      return false;
    }, (user) async {
      await ref.read(authProvider.notifier).setUser(user);
      state = state.copyWith(
        isVerifyingOtp: false,
        isNewUser: user.isNewUser,
      );
      return true;
    });
  }

  Future<void> resendOtp(AppLocalizations l10n) async {
    if (!state.canResend || state.isSendingOtp) return;
    await sendOtp(l10n);
  }

  void clearPhoneError() => state = state.copyWith(clearPhoneError: true);
  void clearOtpError() => state = state.copyWith(clearOtpError: true);

  void reset() {
    _timer?.cancel();
    state = const PhoneAuthState();
  }

  void _startResendCooldown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.resendCooldown <= 1) {
        t.cancel();
        state = state.copyWith(resendCooldown: 0, canResend: true);
      } else {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      }
    });
  }
}

final phoneAuthProvider = StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>(
  (ref) => PhoneAuthNotifier(ref),
);
