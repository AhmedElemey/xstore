import 'dart:math' as math;

import '../../../../core/constants/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/social_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/social_button.dart';
import '../widgets/social_login_row.dart';
import '../../../../shared/widgets/space_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _sheetPhone = TextEditingController();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRememberedPhone());
  }

  Future<void> _loadRememberedPhone() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = prefs.getString(PrefsKeys.rememberedPhone);
    if (saved != null && saved.isNotEmpty && mounted) {
      _phone.text = saved;
      ref.read(loginNotifierProvider.notifier).updatePhone(saved);
      ref.read(loginNotifierProvider.notifier).setRememberMe(true);
    }
  }

  Future<void> _persistRememberedPhone(bool remember, String phone) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (remember) {
      await prefs.setString(PrefsKeys.rememberedPhone, phone);
    } else {
      await prefs.remove(PrefsKeys.rememberedPhone);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _sheetPhone.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final n = ref.read(loginNotifierProvider.notifier);
    n.updatePhone(_phone.text.trim());
    n.updatePassword(_password.text);
    await n.login(context.l10n);
    if (!mounted) return;
    final loginState = ref.read(loginNotifierProvider);
    final authState = ref.read(authProvider);
    if (loginState.error == null && authState.valueOrNull != null) {
      await _persistRememberedPhone(loginState.rememberMe, loginState.phone);
      if (!mounted) return;
      await maybeShowLocationPermissionPrompt(context, ref);
      if (!mounted) return;
      context.go(AppRoutes.home);
    }
  }

  Future<void> _openPhoneLoginSheet() async {
    _sheetPhone.clear();
    ref.read(phoneAuthProvider.notifier).reset();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(phoneAuthProvider);
              final notifier = ref.read(phoneAuthProvider.notifier);
              final hasError = state.phoneError != null && state.phoneError!.isNotEmpty;
              final isValid = state.phoneError == null && state.phoneNumber.length == 11;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.enterYourPhoneNumber,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const Gap(AppSpacing.spacing6),
                  Text(
                    context.l10n.sendOtpSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  PhoneInputField(
                    controller: _sheetPhone,
                    errorText: hasError ? state.phoneError : null,
                    onChanged: (v) => notifier.updatePhone(v, context.l10n),
                  ),
                  const Gap(AppSpacing.lg),
                  XstoreButton(
                    label: context.l10n.sendVerificationCode,
                    isLoading: state.isSendingOtp,
                    onPressed: isValid && !state.isSendingOtp
                        ? () async {
                            final navigator = Navigator.of(context);
                            final ok = await notifier.sendOtp(context.l10n);
                            if (!mounted || !ok) return;
                            // Mock mode sends no real SMS — the fixed test
                            // code is echoed back here for local dev/testing.
                            final debugOtp =
                                ref.read(phoneAuthProvider).debugOtp;
                            if (kDebugMode &&
                                debugOtp != null &&
                                debugOtp.isNotEmpty &&
                                context.mounted) {
                              AppSnackbar.info(context, 'Debug OTP: $debugOtp');
                            }
                            navigator.pop();
                            if (!mounted) return;
                            final authed =
                                ref.read(authProvider).valueOrNull != null;
                            if (authed) {
                              await maybeShowLocationPermissionPrompt(
                                this.context,
                                ref,
                              );
                              if (!mounted) return;
                              this.context.go(AppRoutes.home);
                            } else {
                              this.context.push(AppRoutes.otp);
                            }
                          }
                        : null,
                  ),
                  const Gap(AppSpacing.spacing10),
                  Text(
                    context.l10n.smsRatesNote,
                    textAlign: TextAlign.center,
                    style: AppTypography.body12.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginNotifierProvider);
    ref.listen(loginNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _shakeController.forward(from: 0);
      }
    });
    ref.listen(socialAuthProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev && mounted) {
        AppSnackbar.error(context, next);
      }
    });

    final l10n = context.l10n;
    final phoneFormatError = Validators.egyptPhone(l10n, login.phone.trim());
    final passwordFormatError = Validators.loginPassword(l10n, login.password);
    final notifierAuthError = login.error != null &&
        login.error != phoneFormatError &&
        login.error != passwordFormatError;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SpaceBackground(
        child: Stack(
          children: [
            const PositionedDirectional(
              top: -60,
              end: -70,
              child: _Planet(size: 200),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final t = _shakeController.value;
                    final ox = 10 * (1 - t) * math.sin(t * 6.28318 * 4);
                    return Transform.translate(
                      offset: Offset(ox, 0),
                      child: child,
                    );
                  },
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(
                          showWordmark: true,
                          title: l10n.welcomeBack,
                          subtitle: l10n.signInToContinueShopping,
                        ),
                        const Gap(AppSpacing.x2l),
                        PhoneInputField(
                          controller: _phone,
                          errorText: login.error != null &&
                                  login.error == phoneFormatError
                              ? login.error
                              : null,
                          onChanged: (v) => ref
                              .read(loginNotifierProvider.notifier)
                              .updatePhone(v),
                        ),
                        const Gap(AppSpacing.xl),
                        AuthTextField(
                          label: l10n.password,
                          hint: l10n.enterPasswordHint,
                          controller: _password,
                          obscureText: !login.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          labelTrailing: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            style: TextButton.styleFrom(
                              foregroundColor: context.primaryColor,
                              minimumSize: const Size(44, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                            ),
                            child: Text(
                              l10n.forgotPassword,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => ref
                                .read(loginNotifierProvider.notifier)
                                .togglePasswordVisibility(),
                            icon: Icon(
                              login.isPasswordVisible
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye,
                              color: context.iconSecondary,
                            ),
                          ),
                          errorText: login.error != null &&
                                  login.error == passwordFormatError
                              ? login.error
                              : null,
                          onChanged: (v) => ref
                              .read(loginNotifierProvider.notifier)
                              .updatePassword(v),
                          validator: (v) =>
                              Validators.loginPassword(l10n, v ?? ''),
                        ),
                        if (login.error != null && notifierAuthError) ...[
                          const Gap(AppSpacing.sm),
                          Text(
                            login.error!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        // App-only: remember me.
                        Row(
                          children: [
                            Checkbox(
                              value: login.rememberMe,
                              onChanged: (_) => ref
                                  .read(loginNotifierProvider.notifier)
                                  .toggleRememberMe(),
                            ),
                            Text(
                              l10n.rememberMe,
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        XstoreButton(
                          label: l10n.login,
                          isLoading: login.isLoading,
                          onPressed: login.isLoading ||
                                  phoneFormatError != null ||
                                  passwordFormatError != null
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    await _submit();
                                  }
                                },
                        ),
                        const Gap(AppSpacing.xl),
                        const AuthDivider(),
                        const Gap(AppSpacing.xl),
                        const SocialLoginRow(),
                        const Gap(AppSpacing.md),
                        // App-only: one-time-code login by phone.
                        SocialButton(
                          onTap: _openPhoneLoginSheet,
                          isLoading: false,
                          icon: Icon(
                            LucideIcons.smartphone,
                            size: 20,
                            color: context.textPrimary,
                          ),
                          label: l10n.continueWithPhoneNumber,
                        ),
                        const Gap(AppSpacing.x2l),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: Text.rich(
                              TextSpan(
                                text: '${l10n.dontHaveAccount} ',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: l10n.createOneArrow,
                                    style: TextStyle(
                                      color: context.primaryColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The lit planet peeking in at the top corner of the sign-in screen.
class _Planet extends StatelessWidget {
  const _Planet({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.8,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.36, -0.44),
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFF9EE9FF),
                Color(0xFF6C7BFF),
                Color(0xFF2A1B6B),
                Color(0xFF0C0F2A),
              ],
              stops: [0, 0.12, 0.45, 0.78, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CA0FF).withValues(alpha: 0.5),
                blurRadius: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
