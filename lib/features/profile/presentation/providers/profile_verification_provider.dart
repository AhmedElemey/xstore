import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/otp_resend_cooldown.dart';

/// Which contact field a [ProfileVerificationScreen] is verifying — drives
/// which backend OTP use-cases get called and which copy is shown.
enum ProfileVerificationTarget { email, phone }

/// Immutable args identifying one verification run — used as the
/// `.family` key, so it needs value equality.
class ProfileVerificationArgs {
  const ProfileVerificationArgs({
    required this.target,
    required this.contactValue,
  });

  final ProfileVerificationTarget target;
  final String contactValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileVerificationArgs &&
          other.target == target &&
          other.contactValue == contactValue);

  @override
  int get hashCode => Object.hash(target, contactValue);
}

class ProfileVerificationState {
  const ProfileVerificationState({
    this.isSending = false,
    this.isVerifying = false,
    this.codeSent = false,
    this.error,
    this.resendCooldown = 0,
    this.canResend = false,
    this.verified = false,
    this.debugOtp,
  });

  final bool isSending;
  final bool isVerifying;
  final bool codeSent;

  /// Error code to resolve via l10n at the call site (e.g. 'otpInvalidCode',
  /// 'errorGeneric') — mirrors the pattern used by ProfileState.error.
  final String? error;
  final int resendCooldown;
  final bool canResend;
  final bool verified;

  /// Debug-mode-only OTP echoed by the backend (no real SMTP/SMS gateway
  /// wired yet) — surfaced via a snackbar in kDebugMode only.
  final String? debugOtp;

  ProfileVerificationState copyWith({
    bool? isSending,
    bool? isVerifying,
    bool? codeSent,
    String? error,
    bool clearError = false,
    int? resendCooldown,
    bool? canResend,
    bool? verified,
    String? debugOtp,
  }) {
    return ProfileVerificationState(
      isSending: isSending ?? this.isSending,
      isVerifying: isVerifying ?? this.isVerifying,
      codeSent: codeSent ?? this.codeSent,
      error: clearError ? null : (error ?? this.error),
      resendCooldown: resendCooldown ?? this.resendCooldown,
      canResend: canResend ?? this.canResend,
      verified: verified ?? this.verified,
      debugOtp: debugOtp ?? this.debugOtp,
    );
  }
}

/// Drives the send/verify OTP flow for one contact value (email or phone),
/// via the backend endpoints already wired in auth_provider.dart
/// (send-email-otp/verify-email, send-phone-otp/verify-phone).
class ProfileVerificationNotifier extends StateNotifier<ProfileVerificationState> {
  ProfileVerificationNotifier(this.ref, this.args)
      : super(const ProfileVerificationState());

  final Ref ref;
  final ProfileVerificationArgs args;
  final _cooldown = OtpResendCooldown();

  Future<void> sendCode() async {
    state = state.copyWith(isSending: true, clearError: true);
    final result = args.target == ProfileVerificationTarget.email
        ? await ref.read(sendEmailOtpUseCaseProvider).call(args.contactValue)
        : await ref
            .read(sendPhoneOtpBackendUseCaseProvider)
            .call(args.contactValue);
    if (!mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(isSending: false, error: 'errorGeneric');
      },
      (otp) {
        state = state.copyWith(
          isSending: false,
          codeSent: true,
          resendCooldown: 60,
          canResend: false,
          debugOtp: otp,
          clearError: true,
        );
        _startResendCooldown();
      },
    );
  }

  Future<bool> verify(String otpCode) async {
    if (otpCode.length != 6) return false;
    state = state.copyWith(isVerifying: true, clearError: true);
    final result = args.target == ProfileVerificationTarget.email
        ? await ref.read(verifyEmailOtpUseCaseProvider).call(
              email: args.contactValue,
              otpToken: otpCode,
            )
        : await ref.read(verifyPhoneOtpBackendUseCaseProvider).call(
              phoneNumber: args.contactValue,
              otpToken: otpCode,
            );
    if (!mounted) return false;
    return result.fold(
      (failure) {
        state = state.copyWith(isVerifying: false, error: 'otpInvalidCode');
        return false;
      },
      (_) {
        state = state.copyWith(isVerifying: false, verified: true);
        return true;
      },
    );
  }

  Future<void> resend() async {
    if (!state.canResend || state.isSending) return;
    await sendCode();
  }

  void _startResendCooldown() {
    _cooldown.start(
      (remaining) {
        if (!mounted) return;
        state = state.copyWith(
          resendCooldown: remaining,
          canResend: remaining == 0,
        );
      },
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    _cooldown.cancel();
    super.dispose();
  }
}

final profileVerificationProvider = StateNotifierProvider.autoDispose
    .family<ProfileVerificationNotifier, ProfileVerificationState,
        ProfileVerificationArgs>(
  (ref, args) => ProfileVerificationNotifier(ref, args),
);
