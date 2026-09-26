import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/otp_resend_row.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otp = TextEditingController();
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _shakeAnimation = Tween(begin: 0.0, end: 24.0)
      .chain(CurveTween(curve: Curves.elasticIn))
      .animate(_shakeController);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authed = ref.read(authProvider).valueOrNull;
      if (authed == null || !mounted) return;
      await maybeShowLocationPermissionPrompt(context, ref);
      if (!mounted) return;
      context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _otp.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(phoneAuthProvider);
    ref.listen<String?>(phoneAuthProvider.select((s) => s.otpError), (_, error) {
      if (error != null && error.isNotEmpty) _triggerShake();
    });
    final display = AppValidators.formatEgyptPhone(AppValidators.toE164Egypt(st.phoneNumber));

    Future<void> verify() async {
      final ok = await ref.read(phoneAuthProvider.notifier).verifyOtp();
      if (!context.mounted || !ok) return;
      await maybeShowLocationPermissionPrompt(context, ref);
      if (!context.mounted) return;
      context.go(AppRoutes.home);
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
          child: Center(
            child: OrbitCircleButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                ref.read(phoneAuthProvider.notifier).reset();
                context.pop();
              },
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? LucideIcons.chevronRight
                    : LucideIcons.chevronLeft,
                size: 22,
                color: context.textPrimary,
              ),
            ),
          ),
        ),
      ),
      body: SpaceBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, AppSpacing.sm, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: OrbitGlyphOrb(
                    icon: LucideIcons.messageSquare,
                    size: 64,
                    ringed: true,
                  ),
                ),
                const Gap(AppSpacing.x2l),
                Text(
                  context.l10n.verifyYourNumber,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Text.rich(
                  TextSpan(
                    text: '${context.l10n.otpEnterCodeSentTo} ',
                    children: [
                      TextSpan(
                        text: '+20 $display',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    height: 1.5,
                    color: context.textSecondary,
                  ),
                ),
                const Gap(AppSpacing.x2l),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(sin(_shakeAnimation.value * pi) * 8, 0),
                    child: child,
                  ),
                  child: OtpInputField(
                    controller: _otp,
                    enabled: !st.isVerifyingOtp,
                    errorText: st.otpError,
                    onCompleted: (code) async {
                      ref.read(phoneAuthProvider.notifier).updateOtp(code);
                      await verify();
                    },
                  ),
                ),
                const Gap(AppSpacing.xl),
                Center(
                  child: OtpResendRow(
                    canResend: st.canResend,
                    resendCooldown: st.resendCooldown,
                    isSending: st.isSendingOtp,
                    onResend: () async {
                      await ref
                          .read(phoneAuthProvider.notifier)
                          .resendOtp(context.l10n);
                      if (!context.mounted) return;
                      // Mock mode sends no real SMS — the fixed test
                      // code is echoed back for local dev/testing.
                      final debugOtp = ref.read(phoneAuthProvider).debugOtp;
                      if (kDebugMode &&
                          debugOtp != null &&
                          debugOtp.isNotEmpty) {
                        AppSnackbar.info(context, 'Debug OTP: $debugOtp');
                      }
                    },
                  ),
                ),
                const Gap(AppSpacing.x4l),
                XstoreButton(
                  label: context.l10n.verifyAndContinue,
                  isLoading: st.isVerifyingOtp,
                  onPressed: st.otpCode.length == 6 && !st.isVerifyingOtp
                      ? verify
                      : null,
                ),
                const Gap(AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: context.primaryColor,
                    ),
                    child: Text(context.l10n.changeNumber),
                  ),
                ),
                Text(
                  context.l10n.otpContactSupport,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
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
