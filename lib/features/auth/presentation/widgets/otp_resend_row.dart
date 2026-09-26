import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Cooldown countdown / "Resend Code" action shared by every OTP screen
/// (login OTP, forgot-password reset, profile email/phone verification).
class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    super.key,
    required this.canResend,
    required this.resendCooldown,
    required this.isSending,
    required this.onResend,
  });

  final bool canResend;
  final int resendCooldown;
  final bool isSending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (!canResend) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 16, color: context.textSecondary),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: '${context.l10n.resendCodeIn} ',
              children: [
                TextSpan(
                  text: '0:${resendCooldown.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.didntReceiveCode,
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
        TextButton(
          onPressed: isSending ? null : onResend,
          style: TextButton.styleFrom(foregroundColor: context.primaryColor),
          child: Text(context.l10n.resendCode),
        ),
      ],
    );
  }
}
