import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/app_dialogs.dart';
import '../../core/constants/prefs_keys.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../providers/shared_providers.dart';

/// Shows the "use your location" rationale exactly once ever (persisted
/// flag), then kicks off a silent background location auto-fill for the
/// user's profile.
///
/// Call this at every "auth succeeded, entering the app" site — cold-start
/// session restore (splash), login, OTP login, register, courier login —
/// not just one of them. Auth success can land the user on Home from
/// several different screens, so a single central hook (e.g. splash alone)
/// misses most of them; mirrors `requireLogin`'s "gate at every entry
/// point, not just one redirect" pattern in this same directory.
Future<void> maybeShowLocationPermissionPrompt(
  BuildContext context,
  WidgetRef ref,
) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  if (!context.mounted) return;

  final alreadyShown =
      prefs.getBool(PrefsKeys.locationPermissionRationaleShown) ?? false;

  var canDetect = true;
  if (!alreadyShown) {
    await prefs.setBool(PrefsKeys.locationPermissionRationaleShown, true);
    if (!context.mounted) return;
    final allowed = await showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text(context.l10n.locationPermissionRationaleTitle),
        content: Text(context.l10n.locationPermissionRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.locationPermissionNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.locationPermissionAllow),
          ),
        ],
      ),
    );
    canDetect = allowed ?? false;
  }

  if (canDetect) {
    unawaited(
      ref
          .read(profileNotifierProvider.notifier)
          .autoDetectAndFillLocationIfMissing(),
    );
  }
}
