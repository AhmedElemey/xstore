import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/widgets/phone_verification_sheet.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Gate for account-gated actions the backend already rejects for an
/// unverified phone (creating a listing, placing an order) — checks
/// proactively instead of waiting for the 400/403 to come back.
///
/// Returns true when the phone is already verified, or becomes verified
/// after the user completes the OTP sheet; false if they cancel, the OTP
/// fails, or the widget is gone by the time verification finishes — the
/// caller aborts the action either way.
Future<bool> requirePhoneVerified(BuildContext context, WidgetRef ref) async {
  final profileState = ref.read(profileNotifierProvider);
  if (profileState.profile?.isPhoneVerified ?? false) return true;

  final phone = profileState.profile?.user.phoneNumber ??
      ref.read(authProvider).valueOrNull?.phoneNumber ??
      '';
  if (phone.isEmpty) return false;

  final verified = await verifyPhoneNow(context, ref, phone);
  if (!verified || !context.mounted) return false;

  await ref.read(profileNotifierProvider.notifier).refreshProfileData(force: true);
  return true;
}
