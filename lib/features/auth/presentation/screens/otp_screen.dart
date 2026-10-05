import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/otp_resend_row.dart';
import '../../../../shared/widgets/xstore_button.dart';

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
                        child: AuthBackButton(
                          onPressed: () {
                            ref.read(phoneAuthProvider.notifier).reset();
                            context.pop();
                          },
                        ),
                      ),
                      const Gap(32),
                      const Center(child: _PhoneOrbit()),
                      const Gap(22),
                      Text(
                        context.l10n.verifyYourNumber,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineSmall.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Text.rich(
                        TextSpan(
                          text: '${context.l10n.otpEnterCodeSentTo} ',
                          children: [
                            TextSpan(
                              // Bidi isolate keeps "+20 …" left-to-right
                              // inside Arabic copy.
                              text: '\u2066+20 $display\u2069',
                              style: AppTypography.mono.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: AppTypography.body15.copyWith(
                          height: 1.5,
                          color: context.textSecondary,
                        ),
                      ),
                      const Gap(22),
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
                            final ok = await ref
                                .read(phoneAuthProvider.notifier)
                                .verifyOtp();
                            if (!context.mounted || !ok) return;
                            await maybeShowLocationPermissionPrompt(context, ref);
                            if (!context.mounted) return;
                            context.go(AppRoutes.home);
                          },
                        ),
                      ),
                      const Gap(22),
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
                            final debugOtp =
                                ref.read(phoneAuthProvider).debugOtp;
                            if (kDebugMode &&
                                debugOtp != null &&
                                debugOtp.isNotEmpty) {
                              AppSnackbar.info(context, 'Debug OTP: $debugOtp');
                            }
                          },
                        ),
                      ),
                      const Spacer(),
                      const Gap(AppSpacing.x2l),
                      XstoreButton(
                        label: context.l10n.verifyAndContinue,
                        isLoading: st.isVerifyingOtp,
                        onPressed: st.otpCode.length == 6 && !st.isVerifyingOtp
                            ? () async {
                                final ok = await ref
                                    .read(phoneAuthProvider.notifier)
                                    .verifyOtp();
                                if (!context.mounted || !ok) return;
                                await maybeShowLocationPermissionPrompt(
                                  context,
                                  ref,
                                );
                                if (!context.mounted) return;
                                context.go(AppRoutes.home);
                              }
                            : null,
                      ),
                      const Gap(AppSpacing.sm),
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: context.linkColor,
                            minimumSize: const Size(0, 44),
                          ),
                          child: Text(context.l10n.changeNumber),
                        ),
                      ),
                      Text(
                        context.l10n.otpContactSupport,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: context.labelColor,
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

/// Phone glyph on a small planet inside two orbit rings, with an amber moon.
class _PhoneOrbit extends StatelessWidget {
  const _PhoneOrbit();

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return SizedBox.square(
      dimension: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: 0.4)),
            ),
          ),
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkSecondary.withValues(alpha: 0.35),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [
                  AppColors.white,
                  AppColors.primaryLight,
                  AppColors.primary,
                ],
                stops: [0, 0.4, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.55),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.smartphone,
              size: 28,
              color: AppColors.darkOnBrand,
            ),
          ),
          PositionedDirectional(
            start: 136,
            top: 60,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLight,
                boxShadow: [
                  BoxShadow(color: context.amberColor, blurRadius: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
