import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/auth_back_button.dart';
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
        // Live forgot-password no longer echoes `otp` (same as
        // send-email-otp / send-phone-otp). Only surface a debug snackbar
        // when the API actually returned one.
        if (kDebugMode && debugOtp != null && debugOtp.isNotEmpty) {
          AppSnackbar.info(context, 'Debug OTP: $debugOtp');
        } else {
          AppSnackbar.success(
            context,
            context.l10n.resetCodeSentConfirmation(email),
          );
        }
        context.push(AppRoutes.forgotPasswordOtp, extra: email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AuthBackButton(onPressed: () => context.pop()),
                      ),
                      const Gap(AppSpacing.xl),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _LockPlanet(),
                      ),
                      const Gap(AppSpacing.xl),
                      Text(
                        context.l10n.resetPasswordTitle,
                        style: AppTypography.headlineSmall.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Text(
                        context.l10n.forgotPasswordSubtitle,
                        style: AppTypography.body15.copyWith(
                          height: 1.5,
                          color: context.textSecondary,
                        ),
                      ),
                      const Gap(AppSpacing.x2l),
                      AuthTextField(
                        label: context.l10n.email,
                        hint: context.l10n.enterEmailHint,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _error,
                        onChanged: (_) {
                          if (_error != null) {
                            setState(() => _error = null);
                          }
                        },
                      ),
                      const Spacer(),
                      const Gap(AppSpacing.x2l),
                      ListenableBuilder(
                        listenable: _email,
                        builder: (context, _) => XstoreButton(
                          label: context.l10n.sendResetCode,
                          isLoading: _isLoading,
                          onPressed:
                              _isLoading || _validateEmail(_email.text) != null
                                  ? null
                                  : _sendResetLink,
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: TextButton.styleFrom(
                            foregroundColor: context.linkColor,
                            minimumSize: const Size(0, 44),
                          ),
                          child: Text(context.l10n.backToLogin),
                        ),
                      ),
                    ],
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

/// Violet planet with a lock glyph — the forgot-password emblem.
class _LockPlanet extends StatelessWidget {
  const _LockPlanet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [
            AppColors.white,
            AppColors.darkSecondary,
            AppColors.primaryDark,
          ],
          stops: [0, 0.4, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSecondary.withValues(alpha: 0.5),
            blurRadius: 40,
          ),
        ],
      ),
      child: const Icon(
        LucideIcons.lock,
        size: 34,
        color: AppColors.darkOnBrand,
      ),
    );
  }
}
