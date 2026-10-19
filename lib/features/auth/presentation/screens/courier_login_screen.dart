import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';

/// Demo OTP accepted while courier auth is mock-only. Replaced by the real
/// backend OTP once delivery accounts go live server-side.
const String kCourierDemoOtp = '123456';

enum _CourierLoginMode { password, otp }

/// Dedicated sign-in for platform couriers ("Login as delivery" on the main
/// login screen). Phone + password, or phone + OTP. Reuses the standard
/// [LoginNotifier] flow, so a successful sign-in adopts the session and the
/// role-aware redirect lands couriers on their deliveries run.
class CourierLoginScreen extends ConsumerStatefulWidget {
  const CourierLoginScreen({super.key});

  @override
  ConsumerState<CourierLoginScreen> createState() =>
      _CourierLoginScreenState();
}

class _CourierLoginScreenState extends ConsumerState<CourierLoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();

  var _mode = _CourierLoginMode.password;
  var _otpSent = false;
  String? _localError;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _finishLogin({required String password}) async {
    final n = ref.read(loginNotifierProvider.notifier);
    n.updatePhone(_phone.text.trim());
    n.updatePassword(password);
    await n.login(context.l10n);
    if (!mounted) return;
    final loginState = ref.read(loginNotifierProvider);
    final authState = ref.read(authProvider);
    if (loginState.error == null && authState.valueOrNull != null) {
      await maybeShowLocationPermissionPrompt(context, ref);
      if (!mounted) return;
      // Role-aware redirect routes couriers to /deliveries from here.
      context.go(AppRoutes.home);
    }
  }

  Future<void> _submitPassword() async {
    final err = Validators.egyptPhone(context.l10n, _phone.text) ??
        Validators.loginPassword(context.l10n, _password.text);
    if (err != null) {
      setState(() => _localError = err);
      return;
    }
    setState(() => _localError = null);
    await _finishLogin(password: _password.text);
  }

  void _sendOtp() {
    final err = Validators.egyptPhone(context.l10n, _phone.text);
    if (err != null) {
      setState(() => _localError = err);
      return;
    }
    if (!MockConfig.useMock) {
      // No backend courier accounts (and no courier OTP route) yet.
      AppSnackbar.error(context, context.l10n.courierOtpLiveUnavailable);
      return;
    }
    setState(() {
      _localError = null;
      _otpSent = true;
      _otp.clear();
    });
    AppSnackbar.success(context, context.l10n.courierOtpSentDemo);
  }

  Future<void> _verifyOtp() async {
    if (_otp.text.trim() != kCourierDemoOtp) {
      setState(() => _localError = context.l10n.courierOtpInvalid);
      return;
    }
    setState(() => _localError = null);
    // Mock login accepts any password; the phone routes the role.
    await _finishLogin(password: 'otp-$kCourierDemoOtp');
  }

  bool get _phoneValid =>
      Validators.egyptPhone(context.l10n, _phone.text) == null;

  bool get _passwordValid =>
      Validators.loginPassword(context.l10n, _password.text) == null;

  bool get _otpComplete => _otp.text.trim().length == 6;

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginNotifierProvider);
    final error = _localError ?? login.error;

    // Couriers get the amber "solar" accent: focus ring, cursor, toggle.
    final amber = context.amberColor;
    final theme = Theme.of(context);
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: Theme(
            data: theme.copyWith(
              inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: amber, width: 1.4),
                ),
              ),
              textSelectionTheme: theme.textSelectionTheme.copyWith(
                cursorColor: amber,
              ),
            ),
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
                        const _CourierPlanet(),
                        Text(
                          context.l10n.courierLoginTitle,
                          style: AppTypography.headline.copyWith(
                            fontSize: AppTypography.rem(1.75),
                            color: context.textPrimary,
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        Text(
                          context.l10n.courierLoginSubtitle,
                          style: AppTypography.body15.copyWith(
                            height: 1.45,
                            color: context.textSecondary,
                          ),
                        ),
                        const Gap(AppSpacing.xl),
                        _ModeToggle(
                          mode: _mode,
                          onChanged: login.isLoading
                              ? null
                              : (m) => setState(() {
                                    _mode = m;
                                    _localError = null;
                                    _otpSent = false;
                                  }),
                        ),
                        const Gap(AppSpacing.xl),
                        PhoneInputField(
                          controller: _phone,
                          accentColor: context.amberColor,
                          enabled: !login.isLoading,
                          onChanged: (_) => setState(() => _localError = null),
                        ),
                        if (_mode == _CourierLoginMode.password) ...[
                          const Gap(AppSpacing.lg),
                          AuthTextField(
                            label: context.l10n.courierModePassword,
                            controller: _password,
                            obscureText: !login.isPasswordVisible,
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
                            onChanged: (_) =>
                                setState(() => _localError = null),
                          ),
                        ] else if (_otpSent) ...[
                          const Gap(AppSpacing.lg),
                          AuthTextField(
                            label: context.l10n.courierOtpFieldLabel,
                            hint: context.l10n.courierOtpHint,
                            controller: _otp,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (_) =>
                                setState(() => _localError = null),
                          ),
                        ],
                        if (error != null) ...[
                          const Gap(AppSpacing.md),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Gap(AppSpacing.x2l),
                        if (_mode == _CourierLoginMode.password)
                          XstoreButton(
                            gradient: AppColors.courierGradient,
                            foregroundColor: AppColors.onCourier,
                            label: context.l10n.login,
                            isLoading: login.isLoading,
                            onPressed: login.isLoading ||
                                    !_phoneValid ||
                                    !_passwordValid
                                ? null
                                : _submitPassword,
                          )
                        else if (_otpSent) ...[
                          XstoreButton(
                            gradient: AppColors.courierGradient,
                            foregroundColor: AppColors.onCourier,
                            label: context.l10n.courierVerifyAndLogin,
                            isLoading: login.isLoading,
                            onPressed: login.isLoading || !_otpComplete
                                ? null
                                : _verifyOtp,
                          ),
                          const Gap(AppSpacing.sm),
                          Center(
                            child: TextButton(
                              onPressed: login.isLoading ? null : _sendOtp,
                              style: TextButton.styleFrom(
                                foregroundColor: amber,
                                minimumSize: const Size(0, 44),
                              ),
                              child: Text(context.l10n.courierResendCode),
                            ),
                          ),
                        ] else
                          XstoreButton(
                            gradient: AppColors.courierGradient,
                            foregroundColor: AppColors.onCourier,
                            label: context.l10n.courierSendCode,
                            isLoading: false,
                            onPressed:
                                login.isLoading || !_phoneValid ? null : _sendOtp,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Amber "solar" planet with a delivery truck, on a tilted orbit ring.
class _CourierPlanet extends StatelessWidget {
  const _CourierPlanet();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -10 * pi / 180,
            child: Container(
              width: 300,
              height: 60,
              decoration: ShapeDecoration(
                shape: OvalBorder(
                  side: BorderSide(
                    color: context.amberColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [
                  AppColors.white,
                  AppColors.accentLight,
                  AppColors.accent,
                ],
                stops: [0, 0.4, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentLight.withValues(alpha: 0.5),
                  blurRadius: 50,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.truck,
              size: 44,
              color: AppColors.darkOnBrand,
            ),
          ),
        ],
      ),
    );
  }
}

/// Password | OTP as a frosted segmented pill; the selected side is amber.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _CourierLoginMode mode;
  final ValueChanged<_CourierLoginMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedBg = context.amberColor;
    final selectedFg =
        context.isDark ? AppColors.darkOnBrand : AppColors.white;

    Widget segment(_CourierLoginMode m, String label, IconData icon) {
      final selected = mode == m;
      final fg = selected ? selectedFg : context.textSecondary;
      return Expanded(
        child: Material(
          color: selected ? selectedBg : AppColors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: fg),
                const Gap(AppSpacing.spacing6),
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: context.glassColor,
        shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          segment(
            _CourierLoginMode.password,
            context.l10n.courierModePassword,
            LucideIcons.lock,
          ),
          segment(
            _CourierLoginMode.otp,
            context.l10n.courierModeOtp,
            LucideIcons.messageSquare,
          ),
        ],
      ),
    );
  }
}
