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
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? _validateEmail(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return context.l10n.validationEmailOrPhoneRequired;
    }
    return Validators.registerEmail(context.l10n, trimmed);
  }

  Future<void> _sendResetLink() async {
    final emailError = _validateEmail(_email.text);
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _email.text.trim();
    final result = await ref.read(forgotPasswordUseCaseProvider).call(email);

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.toString();
        });
      },
      (debugOtp) {
        setState(() => _isLoading = false);
        // The backend echoes the OTP in the response while no real
        // email gateway is wired up — surface it for debugging only.
        if (kDebugMode && debugOtp != null && debugOtp.isNotEmpty) {
          AppSnackbar.info(context, 'Debug OTP: $debugOtp');
        }
        context.push(AppRoutes.resetPassword, extra: email);
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.resetPasswordTitle,
                style: AppTypography.titleLarge.copyWith(
                  fontSize: AppTypography.rem(1.625),
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const Gap(AppSpacing.md),
              Text(
                "Enter your email and we'll send you a reset link",
                style: AppTypography.body15.copyWith(
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.spacing28),
              AuthTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(LucideIcons.mail),
                errorText: _error,
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
              const Spacer(),
              XstoreButton(
                label: 'Send Reset Link',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _sendResetLink,
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
