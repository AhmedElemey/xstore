import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/widgets/email_verification_sheet.dart';
import '../../features/auth/presentation/widgets/phone_verification_sheet.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Gate for account-gated actions the backend already rejects for an
/// unverified account (creating a listing, placing an order) — checks
/// proactively instead of waiting for the 400/403 to come back.
///
/// Live `GET /api/auth/get-profile` returns `isEmailVerified` /
/// `isPhoneVerified` (not the `*VerificationRequired` flags). Phone OTP
/// also 400s until email is verified, so this runs email first when
/// needed, then phone.
///
/// Returns true when email and phone are already verified, or become
/// verified after the user completes the OTP sheets; false if they
/// cancel, OTP fails, email/phone is missing, or the widget is gone by
/// the time verification finishes — the caller aborts either way.
Future<bool> requirePhoneVerified(BuildContext context, WidgetRef ref) async {
  var profile = ref.read(profileNotifierProvider).profile;

  if (!(profile?.isEmailVerified ?? false)) {
    final email = profile?.user.email ??
        ref.read(authProvider).valueOrNull?.email ??
        '';
    if (email.isEmpty) return false;
    final emailOk = await verifyEmailNow(context, ref, email);
    if (!emailOk || !context.mounted) return false;
    await ref
        .read(profileNotifierProvider.notifier)
        .refreshProfileData(force: true);
    if (!context.mounted) return false;
    profile = ref.read(profileNotifierProvider).profile;
  }

  if (profile?.isPhoneVerified ?? false) return true;

  final phone = profile?.user.phoneNumber ??
      ref.read(authProvider).valueOrNull?.phoneNumber ??
      '';
  if (phone.isEmpty) return false;

  final verified = await verifyPhoneNow(context, ref, phone);
  if (!verified || !context.mounted) return false;

  await ref.read(profileNotifierProvider.notifier).refreshProfileData(force: true);
  return true;
}
