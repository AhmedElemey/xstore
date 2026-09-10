import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
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
          if (showEmailPrompt) const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          TextButton(
            onPressed: onVerify,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
