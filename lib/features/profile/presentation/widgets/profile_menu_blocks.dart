import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../store/presentation/providers/store_hours_provider.dart';
import '../../../orders/presentation/providers/vendor_orders_provider.dart';
import '../providers/profile_provider.dart';
import 'delete_account_dialog.dart';
import 'profile_menu_section.dart';
import 'profile_menu_tile.dart';
import 'profile_switch_tile.dart';
import 'theme_toggle_tile.dart';
import 'language_toggle_tile.dart';
import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class ProfileMenuBlocks extends ConsumerWidget {
  const ProfileMenuBlocks({
    super.key,
    required this.isVendor,
    required this.onLogout,
  });

  final bool isVendor;
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
    await showAnimatedDialog<void>(
      context: context,
      child: DeleteAccountDialog(
        onConfirm: () =>
            ref.read(profileNotifierProvider.notifier).deleteAccount(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(profileNotifierProvider).pushNotificationsEnabled;
    final email = ref.watch(profileNotifierProvider).emailUpdatesEnabled;
    final pendingVendorOrders = ref.watch(
      vendorOrdersProvider.select((s) => s.pendingCount),
    );
    final storeOpen = ref.watch(
      storeHoursNotifierProvider.select((s) => s.isStoreOpen),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuSection(
          title: context.l10n.sectionMyActivity,
          children: isVendor
              ? [
                  ProfileMenuTile(
                    icon: LucideIcons.layoutGrid,
                    iconBackground: AppColors.primary,
                    label: context.l10n.menuMyListings,
                    onTap: () => context.push(AppRoutes.listingMy),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.clock3,
                    iconBackground: AppColors.primary,
                    label: context.l10n.storeHours,
                    subtitle: storeOpen ? context.l10n.storeOpenNow : context.l10n.storeClosedNow,
                    subtitleColor: storeOpen ? AppColors.success : AppColors.error,
                    onTap: () => context.push(AppRoutes.storeHours),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.shoppingBag,
                    iconBackground: AppColors.accent,
                    label: context.l10n.incomingOrders,
                    trailingBadgeCount: pendingVendorOrders,
                    onTap: () => context.push(AppRoutes.vendorOrders),
                  ),
                  ProfileMenuTile(
                    
                    icon: LucideIcons.barChart2,
                    iconBackground: AppColors.primary,
                    label: context.l10n.menuAnalytics,
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.wallet,
                    iconBackground: AppColors.success,
                    label: context.l10n.menuEarnings,
                    onTap: () => context.push(AppRoutes.earnings),
                  ),
                ]
              : [
                  ProfileMenuTile(
                    icon: LucideIcons.shoppingBag,
                    iconBackground: AppColors.primary,
                    label: context.l10n.menuMyOrders,
                    onTap: () => context.push(AppRoutes.orders),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.heart,
                    iconBackground: AppColors.accent,
                    label: context.l10n.menuWishlist,
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.clock,
                    iconBackground: AppColors.primary,
                    label: context.l10n.menuRecentlyViewed,
                    onTap: () => context.push(AppRoutes.recentlyViewed),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.star,
                    iconBackground: AppColors.success,
                    label: context.l10n.menuMyReviews,
                    onTap: () => context.push(AppRoutes.myReviews),
                  ),
                ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: context.l10n.sectionAccountSettings,
          children: [
            ProfileMenuTile(
              icon: LucideIcons.user,
              iconBackground: AppColors.warning,
              label: context.l10n.menuPersonalInfo,
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
            ProfileMenuTile(
              icon: LucideIcons.lock,
              iconBackground: context.textSecondary,
              label: context.l10n.menuChangePassword,
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            ProfileMenuTile(
              icon: LucideIcons.bell,
              iconBackground: AppColors.accent,
              label: context.l10n.menuNotificationsSettings,
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            ProfileMenuTile(
              icon: LucideIcons.creditCard,
              iconBackground: AppColors.success,
              label: context.l10n.menuPaymentMethods,
              onTap: () => context.push(AppRoutes.paymentMethods),
            ),
            ProfileMenuTile(
              icon: LucideIcons.mapPin,
              iconBackground: AppColors.error,
              label: context.l10n.menuAddresses,
              onTap: () => context.push(AppRoutes.addresses),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: context.l10n.sectionPreferences,
          children: [
            const ThemeToggleTile(),
            const LanguageToggleTile(),
            ProfileSwitchTile(
              icon: LucideIcons.bellOff,
              iconBackground: context.textSecondary,
              label: context.l10n.pushNotifications,
              value: push,
              onChanged: ref.read(profileNotifierProvider.notifier).togglePushNotifications,
            ),
            ProfileSwitchTile(
              icon: LucideIcons.mail,
              iconBackground: AppColors.primary,
              label: context.l10n.emailUpdates,
              value: email,
              onChanged: ref.read(profileNotifierProvider.notifier).toggleEmailUpdates,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: context.l10n.sectionSupport,
          children: [
            ProfileMenuTile(
              icon: LucideIcons.messageCircle,
              iconBackground: AppColors.primary,
              label: context.l10n.menuHelpCenter,
              onTap: () => context.push(AppRoutes.help),
            ),
            ProfileMenuTile(
              icon: LucideIcons.fileText,
              iconBackground: context.textSecondary,
              label: context.l10n.menuTerms,
              onTap: () => context.push(AppRoutes.terms),
            ),
            ProfileMenuTile(
              icon: LucideIcons.shield,
              iconBackground: AppColors.success,
              label: context.l10n.menuPrivacy,
              onTap: () => context.push(AppRoutes.privacy),
            ),
            ProfileMenuTile(
              icon: LucideIcons.star,
              iconBackground: AppColors.warning,
              label: context.l10n.menuRateApp,
              onTap: () => _rateApp(context),
            ),
            ProfileMenuTile(
              icon: LucideIcons.share2,
              iconBackground: AppColors.accent,
              label: context.l10n.menuShareApp,
                    onTap: () => _shareApp(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        Text(
          context.l10n.sectionDangerZone,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: onLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: Text(context.l10n.logOut),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: () => _deleteAccount(context, ref),
            child: Text(
              context.l10n.deleteAccount,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),
        Center(
          child: Text(
            context.l10n.profileFooterLine,
            style: AppTypography.labelSmall.copyWith(color: context.textDisabled),
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
      ],
    );
  }
}
