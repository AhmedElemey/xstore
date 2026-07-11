import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_routes.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Gate for account-bound inline actions (add to cart, wishlist, reviews).
///
/// Returns true when signed in. For guests it shows a sign-in dialog and
/// returns false immediately so the caller aborts — the dialog lets the
/// user choose between going to login or dismissing and continuing to
/// browse. Route-level access is enforced separately in
/// `computeXStoreAuthRedirect`; this covers actions on guest-browsable
/// screens.
bool requireLogin(BuildContext context, WidgetRef ref, {String? message}) {
  final signedIn = ref.read(authProvider).valueOrNull != null;
  if (signedIn) return true;

  // Not awaited on purpose: the caller's action is aborted either way; the
  // dialog outcome only decides whether we navigate to login.
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(LucideIcons.logIn, color: AppColors.primary, size: 40),
      title: Text(dialogContext.l10n.guestLoginRequiredTitle),
      content: Text(
        message ?? dialogContext.l10n.guestLoginRequired,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(dialogContext.l10n.guestLoginDialogNotNow),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            if (context.mounted) context.push(AppRoutes.login);
          },
          child: Text(dialogContext.l10n.guestLoginDialogSignIn),
        ),
      ],
    ),
  );
  return false;
}
