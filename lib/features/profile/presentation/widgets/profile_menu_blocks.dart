import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../addresses/presentation/providers/address_book_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/presentation/providers/vendor_orders_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../../shared/utils/legal_links.dart';
import '../providers/profile_provider.dart';
import 'delete_account_dialog.dart';
import 'profile_menu_section.dart';
import 'profile_menu_tile.dart';
import 'theme_toggle_tile.dart';
import 'language_toggle_tile.dart';
import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class ProfileMenuBlocks extends ConsumerWidget {
  const ProfileMenuBlocks({
    super.key,
    required this.isVendor,
    this.isCourier = false,
    required this.onLogout,
  });

  final bool isVendor;

  /// Couriers get delivery shortcuts instead of the consumer shopping block
  /// (their role is blocked from cart/wishlist/orders by the route guard).
  final bool isCourier;
  final Future<void> Function() onLogout;

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(
      Theme.of(context).platform == TargetPlatform.iOS
          ? context.l10n.iosAppStoreUrl
          : context.l10n.androidPlayStoreUrl,
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      AppSnackbar.error(context, context.l10n.errorGeneric);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await Share.share(context.l10n.shareXStoreMessage);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final hasPassword =
        ref.read(profileNotifierProvider).profile?.hasPassword ??
        ref.read(authProvider).valueOrNull?.hasPassword ??
        true;
    if (!hasPassword) {
      final confirmed = await showAnimatedDialog<bool>(
        context: context,
        child: const PasswordlessDeleteAccountDialog(),
      );
      if (confirmed != true || !context.mounted) return;
      await _submitAccountDeletion(
        context,
        ref,
        confirmationText: context.l10n.deleteConfirmKeyword,
      );
      return;
    }

    await showAnimatedDialog<void>(
      context: context,
      child: DeleteAccountDialog(
        onConfirm: (password, confirmationText) => _submitAccountDeletion(
          context,
          ref,
          password: password,
          confirmationText: confirmationText,
        ),
      ),
    );
  }

  Future<void> _submitAccountDeletion(
    BuildContext context,
    WidgetRef ref, {
    String? password,
    required String confirmationText,
  }) async {
    final result = await ref
        .read(profileNotifierProvider.notifier)
        .deleteAccount(password: password, confirmationText: confirmationText);
    if (result.deleted) {
      await ref.read(authProvider.notifier).logout();
      return;
    }
    if (!context.mounted || result.error == null) return;
    AppSnackbar.error(context, resolveAppError(context, result.error));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingVendorOrders = ref.watch(
      vendorOrdersProvider.select((s) => s.pendingCount),
    );
    final shopper = !isVendor && !isCourier;
    final activeOrders = shopper
        ? ref.watch(
            ordersNotifierProvider.select(
              (s) => s.orders.where((o) => OrderTab.active.includes(o.status)).length,
            ),
          )
        : 0;
    final wishlistCount = shopper
        ? ref.watch(wishlistProvider.select((s) => s.itemCount))
        : 0;
    final addressCount = shopper
        ? ref.watch(addressBookProvider.select((list) => list.length))
        : 0;
    const gap = SizedBox(height: AppSpacing.md + 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuSection(
          children: isVendor
              ? [
                  // Shell-branch tabs — switch with go, never push
                  // (see StatefulShellRoute lesson).
                  ProfileMenuTile(
                    icon: LucideIcons.layoutGrid,
                    iconColor: context.primaryColor,
                    label: context.l10n.menuMyListings,
                    onTap: () => context.go(AppRoutes.listingMy),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.shoppingBag,
                    iconColor: context.cashColor,
                    label: context.l10n.incomingOrders,
                    trailingBadgeCount: pendingVendorOrders,
                    onTap: () => context.go(AppRoutes.vendorOrders),
                  ),
                ]
              : isCourier
                  ? [
                      // Shell-branch tabs — switch with go, never push.
                      ProfileMenuTile(
                        icon: LucideIcons.truck,
                        iconColor: context.primaryColor,
                        label: context.l10n.navDeliveries,
                        onTap: () => context.go(AppRoutes.deliveries),
                      ),
                      ProfileMenuTile(
                        icon: LucideIcons.wallet,
                        iconColor: context.cashColor,
                        label: context.l10n.navCash,
                        onTap: () => context.go(AppRoutes.courierCash),
                      ),
                    ]
                  : [
                      ProfileMenuTile(
                        icon: LucideIcons.package,
                        iconColor: context.primaryColor,
                        label: context.l10n.menuMyOrders,
                        value: activeOrders > 0
                            ? context.l10n.profileOrdersActive(activeOrders)
                            : null,
                        // Shell-branch tab — go, never push.
                        onTap: () => context.go(AppRoutes.orders),
                      ),
                      ProfileMenuTile(
                        icon: LucideIcons.heart,
                        iconColor: _pink,
                        label: context.l10n.menuWishlist,
                        value: wishlistCount > 0 ? '$wishlistCount' : null,
                        onTap: () => context.push(AppRoutes.wishlist),
                      ),
                      // Saved delivery addresses only matter for the buying
                      // flow, so vendors and couriers don't get this row.
                      ProfileMenuTile(
                        icon: LucideIcons.mapPin,
                        iconColor: context.cashColor,
                        label: context.l10n.menuAddresses,
                        value: addressCount > 0 ? '$addressCount' : null,
                        onTap: () => context.push(AppRoutes.addresses),
                      ),
                    ],
        ),
        gap,
        // Parked for phase 2 (restore from the pre-Orbit history of this
        // file): My packages, notification settings, payment methods, help
        // center, and the push/email preference toggles.
        ProfileMenuSection(
          children: [
            ProfileMenuTile(
              icon: LucideIcons.lock,
              iconColor: AppColors.nova,
              label: context.l10n.menuChangePassword,
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            const LanguageToggleTile(),
          ],
        ),
        gap,
        // App-only settings and links the design has no slot for.
        const ProfileMenuSection(children: [ThemeToggleTile()]),
        gap,
        ProfileMenuSection(
          children: [
            ProfileMenuTile(
              icon: LucideIcons.fileText,
              iconColor: AppColors.nova,
              label: context.l10n.menuTerms,
              onTap: () => launchLegalUrl(xstoreTermsUrl),
            ),
            ProfileMenuTile(
              icon: LucideIcons.shield,
              iconColor: AppColors.success,
              label: context.l10n.menuPrivacy,
              onTap: () => launchLegalUrl(xstorePrivacyUrl),
            ),
            ProfileMenuTile(
              icon: LucideIcons.star,
              iconColor: context.cashColor,
              label: context.l10n.menuRateApp,
              onTap: () => _rateApp(context),
            ),
            ProfileMenuTile(
              icon: LucideIcons.share2,
              iconColor: context.primaryColor,
              label: context.l10n.menuShareApp,
              onTap: () => _shareApp(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onLogout,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorLight,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(
                  context.l10n.logOut,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => _deleteAccount(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(
                  context.l10n.deleteAccount,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            context.l10n.profileFooterLine,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
      ],
    );
  }
}

/// Wishlist heart tint from the design.
const _pink = Color(0xFFFF7A8A);
