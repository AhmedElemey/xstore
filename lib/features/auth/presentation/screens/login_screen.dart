import 'dart:math' as math;

import '../../../../core/constants/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
import '../../../../shared/widgets/orbit_background.dart';
import '../widgets/google_sign_in_button.dart';

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
    ref.listen(socialAuthProvider.select((s) => s.googleRegistration), (prev, next) {
      if (next != null && mounted) {
        ref.read(socialAuthProvider.notifier).acknowledgeNeedsRegistration();
        AppSnackbar.info(context, context.l10n.googleAccountNotFound);
        context.go(AppRoutes.register, extra: next);
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
      body: OrbitBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const PositionedDirectional(
                end: -70,
                top: -100,
                child: Opacity(opacity: 0.8, child: OrbitPlanet(size: 200)),
              ),
              SingleChildScrollView(
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
                          title: l10n.welcomeBack,
                          subtitle: l10n.signInToContinueShopping,
                        ),
                        const Gap(AppSpacing.xl),
                        _LoginRegisterTabs(
                          onRegisterTap: () =>
                              context.push(AppRoutes.register),
                        ),
                        const Gap(AppSpacing.xl),
                        PhoneInputField(
                          controller: _phone,
                          errorText:
                              login.error != null && login.error == phoneFormatError
                                  ? login.error
                                  : null,
                          onChanged: (v) =>
                              ref.read(loginNotifierProvider.notifier).updatePhone(v),
                        ),
                        const Gap(AppSpacing.lg),
                        AuthTextField(
                          label: l10n.password,
                          hint: l10n.passwordMask,
                          controller: _password,
                          obscureText: !login.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          labelTrailing: GestureDetector(
                            onTap: () => context.push(AppRoutes.forgotPassword),
                            child: Text(
                              l10n.forgotPassword,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.linkColor,
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
                          errorText:
                              login.error != null && login.error == passwordFormatError
                                  ? login.error
                                  : null,
                          onChanged: (v) => ref
                              .read(loginNotifierProvider.notifier)
                              .updatePassword(v),
                          validator: (v) =>
                              Validators.loginPassword(context.l10n, v ?? ''),
                        ),
                        if (login.error != null && notifierAuthError) ...[
                          const Gap(AppSpacing.sm),
                          Text(
                            login.error!,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ],
                        const Gap(AppSpacing.sm),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => ref
                              .read(loginNotifierProvider.notifier)
                              .toggleRememberMe(),
                          child: Row(
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
                        ),
                        const Gap(AppSpacing.md),
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
                        const Gap(AppSpacing.md),
                        const GoogleSignInButton(),
                        const Gap(AppSpacing.x2l),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: Text.rich(
                              TextSpan(
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: '${l10n.dontHaveAccount}  '),
                                  TextSpan(
                                    text: l10n.createOneArrow,
                                    style: TextStyle(
                                      color: context.linkColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Login | Register as a frosted segmented pill; Login is the current page.
class _LoginRegisterTabs extends StatelessWidget {
  const _LoginRegisterTabs({required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg =
        context.isDark ? AppColors.darkTextPrimary : AppColors.primary;
    final selectedFg =
        context.isDark ? AppColors.darkBackground : AppColors.white;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: context.glassColor,
        shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: selectedBg,
                shape: const StadiumBorder(),
              ),
              child: Text(
                context.l10n.login,
                style: AppTypography.labelLarge.copyWith(
                  color: selectedFg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onRegisterTap,
              child: Center(
                child: Text(
                  context.l10n.register,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
