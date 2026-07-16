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
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/guest_mode_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/social_button.dart';
import '../widgets/social_login_row.dart';

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

    final l10n = context.l10n;
    final phoneFormatError = Validators.egyptPhone(l10n, login.phone.trim());
    final passwordFormatError = Validators.loginPassword(l10n, login.password);
    final notifierAuthError = login.error != null &&
        login.error != phoneFormatError &&
        login.error != passwordFormatError;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 50,
            child: AuthHeader(
              heightFraction: 1,
              title: context.l10n.welcomeBack,
              subtitle: context.l10n.signInToContinueShopping,
              logoSize: 32,
            ),
          ),
          Expanded(
            flex: 90,
            child: Transform.translate(
              offset: const Offset(0, -24),
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
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: context.cardShadowColor,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 15, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          label: context.l10n.password,
                          hint: context.l10n.passwordMask,
                          controller: _password,
                          obscureText: !login.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(LucideIcons.lock),
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
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: Text(
                              context.l10n.forgotPassword,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: login.rememberMe,
                              activeColor: AppColors.primary,
                              onChanged: (_) => ref
                                  .read(loginNotifierProvider.notifier)
                                  .toggleRememberMe(),
                            ),
                            Text(
                              context.l10n.rememberMe,
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.sm),
                        XstoreButton(
                          label: context.l10n.login,
                          isLoading: login.isLoading,
                          onPressed: login.isLoading
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
                        const Gap(AppSpacing.md),
                        SocialButton(
                          onTap: _openPhoneLoginSheet,
                          isLoading: false,
                          icon: Icon(
                            LucideIcons.smartphone,
                            size: 22,
                            color: context.textPrimary,
                          ),
                          label: context.l10n.continueWithPhoneNumber,
                          borderColor: context.borderColor,
                          bgColor: AppColors.transparent,
                          textColor: context.textPrimary,
                        ),
                        const Gap(AppSpacing.md),
                        const SocialLoginRow(),
                        const Gap(AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.register),
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                ),
                                children: [
                                  TextSpan(text: '${context.l10n.dontHaveAccount}  '),
                                  TextSpan(
                                    text: context.l10n.createOneArrow,
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              await ref
                                  .read(guestModeProvider.notifier)
                                  .enable();
                              if (!context.mounted) return;
                              context.go(AppRoutes.home);
                            },
                            child: Text(
                              context.l10n.guestContinue,
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRegisterTabs extends StatelessWidget {
  const _LoginRegisterTabs({required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                context.l10n.login,
                style: AppTypography.navTabLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const Gap(AppSpacing.sm),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onRegisterTap,
            child: Column(
              children: [
                Text(
                  context.l10n.register,
                  style: AppTypography.navTabMedium.copyWith(
                    color: context.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                const Gap(AppSpacing.sm),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
