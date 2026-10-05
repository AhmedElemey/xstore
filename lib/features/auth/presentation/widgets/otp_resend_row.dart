import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final muted = AppTypography.bodyMedium.copyWith(color: context.labelColor);
    if (!canResend) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 16, color: context.labelColor),
          const Gap(8),
          Text('${context.l10n.resendCodeIn} ', style: muted),
          Text(
            '0:${resendCooldown.toString().padLeft(2, '0')}',
            textDirection: TextDirection.ltr,
            style: AppTypography.mono.copyWith(
              fontSize: 14,
              color: context.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(context.l10n.didntReceiveCode, style: muted)),
        TextButton(
          onPressed: isSending ? null : onResend,
          style: TextButton.styleFrom(foregroundColor: context.linkColor),
          child: Text(context.l10n.resendCode),
        ),
      ],
    );
  }
}
