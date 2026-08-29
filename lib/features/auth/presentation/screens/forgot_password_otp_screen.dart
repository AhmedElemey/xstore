import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../providers/otp_resend_cooldown.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/otp_resend_row.dart';
import 'reset_password_screen.dart';

/// Second step of forgot-password: enter the OTP emailed by
/// [ForgotPasswordScreen]. Does not call the verify endpoint — that
/// needs the new password too, so Continue only forwards [email] + OTP
/// to [ResetPasswordScreen].
class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  const ForgotPasswordOtpScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState
    extends ConsumerState<ForgotPasswordOtpScreen> {
  final _otp = TextEditingController();
  final _cooldown = OtpResendCooldown();
  bool _isResending = false;
  bool _continuing = false;
  int _resendCooldown = 60;
  bool _canResend = false;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _otp.addListener(_onOtpChanged);
    // OTP was already sent by ForgotPasswordScreen right before this
    // screen opened — start the same 60s cooldown other OTP screens use.
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otp.removeListener(_onOtpChanged);
    _cooldown.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (mounted) setState(() {});
  }

  void _startResendCooldown() {
    _cooldown.start(
      (remaining) {
        if (!mounted) return;
        setState(() {
          _resendCooldown = remaining;
          _canResend = remaining == 0;
        });
      },
      isMounted: () => mounted,
    );
  }

  Future<void> _resend() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);
    final result =
        await ref.read(forgotPasswordUseCaseProvider).call(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    result.fold(
      (failure) => AppSnackbar.error(context, context.l10n.errorGeneric),
      (debugOtp) {
        _startResendCooldown();
        // Live forgot-password no longer echoes `otp`.
        if (kDebugMode && debugOtp != null && debugOtp.isNotEmpty) {
          AppSnackbar.info(context, 'Debug OTP: $debugOtp');
        } else {
          AppSnackbar.success(
            context,
            context.l10n.resetCodeSentConfirmation(widget.email),
          );
        }
      },
    );
  }

  Future<void> _continue() async {
    if (_otp.text.length != 6 || _continuing) {
      if (_otp.text.length != 6) {
        setState(() => _otpError = context.l10n.otpInvalidCode);
      }
      return;
    }
    setState(() {
      _continuing = true;
      _otpError = null;
    });
    await context.push(
      AppRoutes.resetPassword,
      extra: ResetPasswordArgs(
        email: widget.email,
        otpToken: _otp.text,
      ),
    );
    if (!mounted) return;
    setState(() => _continuing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.iconPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.resetPasswordTitle,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const Gap(AppSpacing.md),
              Text(
                context.l10n.resetPasswordOtpSentTo(widget.email),
                style: AppTypography.body15.copyWith(
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.spacing28),
              Center(
                child: OtpInputField(
                  controller: _otp,
                  enabled: !_continuing,
                  errorText: _otpError,
                  onCompleted: (_) => _continue(),
                ),
              ),
              const Gap(AppSpacing.md),
              Center(
                child: OtpResendRow(
                  canResend: _canResend,
                  resendCooldown: _resendCooldown,
                  isSending: _isResending,
                  onResend: _resend,
                ),
              ),
              const Gap(AppSpacing.xl),
              XstoreButton(
                label: context.l10n.continueLabel,
                isLoading: _continuing,
                onPressed: _otp.text.length == 6 && !_continuing
                    ? _continue
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
