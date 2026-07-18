import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginNotifierProvider);
    final error = _localError ?? login.error;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.courierLoginTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.truck,
                  size: 34,
                  color: context.primaryColor,
                ),
              ),
              const Gap(AppSpacing.md),
              Text(
                context.l10n.courierLoginSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.lg),
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
              const Gap(AppSpacing.lg),
              PhoneInputField(
                controller: _phone,
                enabled: !login.isLoading,
                onChanged: (_) => setState(() => _localError = null),
              ),
              const Gap(AppSpacing.md),
              if (_mode == _CourierLoginMode.password) ...[
                AuthTextField(
                  label: context.l10n.courierModePassword,
                  controller: _password,
                  obscureText: true,
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  onChanged: (_) => setState(() => _localError = null),
                ),
                const Gap(AppSpacing.lg),
                XstoreButton(
                  label: context.l10n.login,
                  isLoading: login.isLoading,
                  onPressed: login.isLoading ? null : _submitPassword,
                ),
              ] else ...[
                if (_otpSent) ...[
                  AuthTextField(
                    label: context.l10n.courierOtpFieldLabel,
                    hint: context.l10n.courierOtpHint,
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (_) => setState(() => _localError = null),
                  ),
                  const Gap(AppSpacing.lg),
                  XstoreButton(
                    label: context.l10n.courierVerifyAndLogin,
                    isLoading: login.isLoading,
                    onPressed: login.isLoading ? null : _verifyOtp,
                  ),
                  const Gap(AppSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: login.isLoading ? null : _sendOtp,
                      child: Text(context.l10n.courierResendCode),
                    ),
                  ),
                ] else
                  XstoreButton(
                    label: context.l10n.courierSendCode,
                    isLoading: false,
                    onPressed: login.isLoading ? null : _sendOtp,
                  ),
              ],
              if (error != null) ...[
                const Gap(AppSpacing.md),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _CourierLoginMode mode;
  final ValueChanged<_CourierLoginMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(_CourierLoginMode m, String label, IconData icon) {
      final selected = mode == m;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          onTap: onChanged == null ? null : () => onChanged!(m),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: selected ? context.primaryColor : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : context.textSecondary,
                ),
                const Gap(AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: selected ? Colors.white : context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          chip(
            _CourierLoginMode.password,
            context.l10n.courierModePassword,
            LucideIcons.lock,
          ),
          chip(
            _CourierLoginMode.otp,
            context.l10n.courierModeOtp,
            LucideIcons.messageSquare,
          ),
        ],
      ),
    );
  }
}
