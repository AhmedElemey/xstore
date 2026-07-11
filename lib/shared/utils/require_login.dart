import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_routes.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../widgets/xstore_button.dart';

/// Gate for account-bound inline actions (add to cart, wishlist, reviews,
/// notifications, account-bound nav taps).
///
/// Returns true when signed in. For guests it shows the sign-in sheet and
/// returns false immediately so the caller aborts — the sheet lets the
/// user choose between going to login or dismissing and continuing to
/// browse. Route-level access is enforced separately in
/// `computeXStoreAuthRedirect`; this covers taps on guest-browsable
/// screens.
bool requireLogin(BuildContext context, WidgetRef ref, {String? message}) {
  final signedIn = ref.read(authProvider).valueOrNull != null;
  if (signedIn) return true;

  // Not awaited on purpose: the caller's action is aborted either way; the
  // sheet outcome only decides whether we navigate to login.
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _LoginRequiredSheet(message: message),
  );
  return false;
}

class _LoginRequiredSheet extends StatelessWidget {
  const _LoginRequiredSheet({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.logIn,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.guestLoginRequiredTitle,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ?? context.l10n.guestLoginRequired,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            XstoreButton(
              label: context.l10n.guestLoginDialogSignIn,
              onPressed: () {
                // Resolve the router before popping — the sheet's context
                // is unmounted after pop and can't be used to navigate.
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push(AppRoutes.login);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.guestLoginDialogNotNow,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
