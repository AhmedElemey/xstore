import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../providers/phone_auth_provider.dart';
import '../widgets/otp_input_field.dart';

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
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        ref.read(phoneAuthProvider.notifier).reset();
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.smartphone, color: Colors.white, size: 80),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Text(
                      context.l10n.verifyYourNumber,
                      style: AppTypography.titleLarge.copyWith(color: context.textPrimary),
                    ),
                    const Gap(AppSpacing.sm),
                    Text(
                      'Enter the 6-digit code sent to',
                      style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
                    ),
                    const Gap(AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🇪🇬 +20 $display',
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(context.l10n.changeNumber),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.lg),
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
                          final ok = await ref.read(phoneAuthProvider.notifier).verifyOtp();
                          if (!context.mounted || !ok) return;
                          context.go(AppRoutes.home);
                        },
                      ),
                    ),
                    const Gap(AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: st.otpCode.length == 6 && !st.isVerifyingOtp
                            ? () async {
                                final ok = await ref.read(phoneAuthProvider.notifier).verifyOtp();
                                if (!context.mounted || !ok) return;
                                context.go(AppRoutes.home);
                              }
                            : null,
                        child: st.isVerifyingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.l10n.verifyAndContinue),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    if (!st.canResend)
                      Text(
                        '${context.l10n.resendCodeIn} 0:${st.resendCooldown.toString().padLeft(2, '0')}',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.didntReceiveCode,
                            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => ref.read(phoneAuthProvider.notifier).resendOtp(),
                            child: Text(context.l10n.resendCode),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Text(
                      'Having trouble? Contact Support',
                      style: AppTypography.labelSmall.copyWith(color: context.textDisabled),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
