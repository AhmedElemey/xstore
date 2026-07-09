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
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/otp_input_field.dart';

/// Second step of the forgot-password flow: enter the OTP sent to [email]
/// plus a new password. See [ForgotPasswordScreen] for the first step.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLoading = false;
  String? _otpError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final passwordError = Validators.registerPassword(l10n, _password.text);
    final confirmError = Validators.confirmPasswordMatches(
      l10n,
      _password.text,
      _confirm.text,
    );
    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    if (_otp.text.length != 6 || passwordError != null || confirmError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    final result = await ref.read(verifyForgotPasswordOtpUseCaseProvider).call(
          email: widget.email,
          otpToken: _otp.text,
          newPassword: _password.text,
          confirmNewPassword: _confirm.text,
        );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _otpError = failure.toString();
        });
      },
      (_) {
        setState(() => _isLoading = false);
        AppSnackbar.success(context, context.l10n.passwordResetSuccess);
        context.go(AppRoutes.login);
      },
    );
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
                  enabled: !_isLoading,
                  errorText: _otpError,
                  onCompleted: (_) => setState(() {}),
                ),
              ),
              const Gap(AppSpacing.xl),
              AuthTextField(
                label: context.l10n.newPasswordRequired,
                controller: _password,
                obscureText: true,
                prefixIcon: const Icon(LucideIcons.lock),
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const Gap(AppSpacing.inputContentPaddingH),
              AuthTextField(
                label: context.l10n.confirmPasswordRequired,
                controller: _confirm,
                obscureText: true,
                prefixIcon: const Icon(LucideIcons.shieldCheck),
                errorText: _confirmError,
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              const Gap(AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.resetPassword,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
