import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../auth/presentation/widgets/otp_input_field.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_verification_provider.dart';

/// Sends and verifies a backend OTP for either the profile email or phone
/// field (`send-email-otp`/`verify-email` or `send-phone-otp`/`verify-phone`),
/// then refreshes the profile so the caller sees the new isEmailVerified /
/// isPhoneNumberVerified flags. Pushed from EditProfileScreen with
/// `extra: ProfileVerificationArgs(...)`; pops `true` on success.
class ProfileVerificationScreen extends ConsumerStatefulWidget {
  const ProfileVerificationScreen({super.key, required this.args});

  final ProfileVerificationArgs args;

  @override
  ConsumerState<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState
    extends ConsumerState<ProfileVerificationScreen> {
  final _otp = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otp.addListener(_onOtpChanged);
    ref.read(profileVerificationProvider(widget.args).notifier).sendCode();
  }

  @override
  void dispose() {
    _otp.removeListener(_onOtpChanged);
    _otp.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (mounted) setState(() {});
  }

  String? _errorText(String? code) {
    return switch (code) {
      'otpInvalidCode' => context.l10n.otpInvalidCode,
      'errorGeneric' => context.l10n.errorGeneric,
      _ => null,
    };
  }

  Future<void> _verify() async {
    await ref
        .read(profileVerificationProvider(widget.args).notifier)
        .verify(_otp.text.trim());
  }

  Future<void> _handleVerified() async {
    await ref
        .read(profileNotifierProvider.notifier)
        .refreshProfileData(force: true);
    if (!mounted) return;
    final isEmail = widget.args.target == ProfileVerificationTarget.email;
    AppSnackbar.success(
      context,
      isEmail
          ? context.l10n.emailVerifiedSuccess
          : context.l10n.phoneVerifiedSuccess,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isEmail = args.target == ProfileVerificationTarget.email;
    final state = ref.watch(profileVerificationProvider(args));

    ref.listen<ProfileVerificationState>(
      profileVerificationProvider(args),
      (prev, next) {
        if (prev?.verified != true && next.verified) {
          _handleVerified();
          return;
        }
        if (kDebugMode &&
            prev?.debugOtp != next.debugOtp &&
            next.debugOtp != null &&
            next.debugOtp!.isNotEmpty) {
          AppSnackbar.info(context, 'Debug OTP: ${next.debugOtp}');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEmail ? context.l10n.verifyYourEmail : context.l10n.verifyYourNumber,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${context.l10n.codeSentTo} ${args.contactValue}',
                style: AppTypography.bodyMedium
                    .copyWith(color: context.textSecondary),
              ),
              const Gap(AppSpacing.xl),
              Center(
                child: OtpInputField(
                  controller: _otp,
                  enabled: !state.isVerifying,
                  errorText: _errorText(state.error),
                  onCompleted: (_) => _verify(),
                ),
              ),
              const Gap(AppSpacing.lg),
              XstoreButton(
                label: context.l10n.verifyAndContinue,
                isLoading: state.isVerifying,
                onPressed: _otp.text.length == 6 && !state.isVerifying
                    ? _verify
                    : null,
              ),
              const Gap(AppSpacing.md),
              Center(
                child: !state.canResend
                    ? Text(
                        '${context.l10n.resendCodeIn} 0:${state.resendCooldown.toString().padLeft(2, '0')}',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    : TextButton(
                        onPressed: state.isSending
                            ? null
                            : () => ref
                                .read(profileVerificationProvider(args).notifier)
                                .resend(),
                        child: Text(context.l10n.resendCode),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
