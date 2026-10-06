import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/require_phone_verified.dart';
import '../../../auth/presentation/widgets/email_verification_sheet.dart';
import '../providers/profile_provider.dart';

/// Surfaces unverified email/phone from GET `/api/auth/get-profile`.
/// Live responses expose `isEmailVerified`/`isPhoneVerified`, not the
/// `*VerificationRequired` flags. Phone "Verify Now" runs email-then-phone
/// because `send-phone-otp` 400s until email is verified.
///
/// Empty / all-zero phones (`000000000`) are treated as unset: the badge
/// asks the user to add a number (Edit Profile) instead of verifying a
/// placeholder.
class ProfileVerificationBanner extends ConsumerWidget {
  const ProfileVerificationBanner({
    super.key,
    required this.email,
    required this.phoneNumber,
    required this.showEmailPrompt,
    required this.showPhonePrompt,
  });

  final String email;
  final String phoneNumber;
  final bool showEmailPrompt;
  final bool showPhonePrompt;

  Future<void> _onVerified(WidgetRef ref) {
    return ref
        .read(profileNotifierProvider.notifier)
        .refreshProfileData(force: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showEmailPrompt && !showPhonePrompt) return const SizedBox.shrink();

    final phoneMissing = AppValidators.isMissingPhoneNumber(phoneNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showEmailPrompt)
          _VerificationRow(
            message: context.l10n.profileEmailNotVerified,
            actionLabel: context.l10n.verifyNow,
            onVerify: () async {
              final ok = await verifyEmailNow(context, ref, email);
              if (ok) await _onVerified(ref);
            },
          ),
        if (showPhonePrompt) ...[
          if (showEmailPrompt) const SizedBox(height: AppSpacing.sm),
          _VerificationRow(
            message: phoneMissing
                ? context.l10n.profilePhoneMissing
                : context.l10n.profilePhoneNotVerified,
            actionLabel: phoneMissing
                ? context.l10n.addNow
                : context.l10n.verifyNow,
            onVerify: () async {
              if (phoneMissing) {
                await context.push(AppRoutes.profileEdit);
                return;
              }
              final ok = await requirePhoneVerified(context, ref);
              if (ok) await _onVerified(ref);
            },
          ),
        ],
      ],
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.message,
    required this.actionLabel,
    required this.onVerify,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.amberColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: context.amberColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onVerify,
            style: TextButton.styleFrom(foregroundColor: context.linkColor),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
