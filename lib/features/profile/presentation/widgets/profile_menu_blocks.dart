import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../orders/presentation/providers/vendor_orders_provider.dart';
import '../providers/profile_provider.dart';
import 'delete_account_dialog.dart';
import 'profile_menu_section.dart';
import 'profile_menu_tile.dart';
import 'profile_switch_tile.dart';
import 'theme_toggle_tile.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProfileMenuBlocks extends ConsumerWidget {
  const ProfileMenuBlocks({
    super.key,
    required this.isVendor,
    required this.onLogout,
  });

  final bool isVendor;
  final Future<void> Function() onLogout;

  Future<void> _languageSheet(BuildContext context, WidgetRef ref) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (!context.mounted) return;
    var lang = prefs.getString(PrefsKeys.profileAppLanguage) ?? 'en';
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setS) {
            Future<void> pick(String code) async {
              await prefs.setString(PrefsKeys.profileAppLanguage, code);
              setS(() => lang = code);
              if (ctx.mounted) Navigator.pop(ctx);
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(AppStrings.languageTitle, style: AppTypography.titleMedium),
                  ),
                  ListTile(
                    title: Text(AppStrings.languageEnglish),
                    trailing: lang == 'en' ? const Icon(Icons.check) : null,
                    onTap: () => pick('en'),
                  ),
                  ListTile(
                    title: Text(AppStrings.languageFrench),
                    trailing: lang == 'fr' ? const Icon(Icons.check) : null,
                    onTap: () => pick('fr'),
                  ),
                  ListTile(
                    title: Text(AppStrings.languageArabic),
                    trailing: lang == 'ar' ? const Icon(Icons.check) : null,
                    onTap: () => pick('ar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(
      Theme.of(context).platform == TargetPlatform.iOS
          ? AppStrings.iosAppStoreUrl
          : AppStrings.androidPlayStoreUrl,
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.errorGeneric)),
      );
    }
  }

  Future<void> _shareApp() async {
    await Share.share(AppStrings.shareXStoreMessage);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => DeleteAccountDialog(
        onConfirm: () => ref.read(profileNotifierProvider.notifier).deleteAccount(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(profileNotifierProvider).pushNotificationsEnabled;
    final email = ref.watch(profileNotifierProvider).emailUpdatesEnabled;
    final vendorOrdersState = ref.watch(vendorOrdersProvider);
    final pendingVendorOrders = vendorOrdersState.pendingCount;
    if (isVendor && !vendorOrdersState.isLoading && vendorOrdersState.totalCount == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(vendorOrdersProvider.notifier).fetchOrders();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuSection(
          title: AppStrings.sectionMyActivity,
          children: isVendor
              ? [
                  ProfileMenuTile(
                    icon: LucideIcons.layoutGrid,
                    iconBackground: AppColors.primary,
                    label: AppStrings.menuMyListings,
                    onTap: () => context.push(AppRoutes.listingMy),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.shoppingBag,
                    iconBackground: AppColors.accent,
                    label: AppStrings.incomingOrders,
                    trailingBadgeCount: pendingVendorOrders,
                    onTap: () => context.push(AppRoutes.vendorOrders),
                  ),
                  ProfileMenuTile(
                    
                    icon: LucideIcons.barChart2,
                    iconBackground: AppColors.primary,
                    label: AppStrings.menuAnalytics,
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.wallet,
                    iconBackground: AppColors.success,
                    label: AppStrings.menuEarnings,
                    onTap: () => context.push(AppRoutes.earnings),
                  ),
                ]
              : [
                  ProfileMenuTile(
                    icon: LucideIcons.shoppingBag,
                    iconBackground: AppColors.primary,
                    label: AppStrings.menuMyOrders,
                    onTap: () => context.push(AppRoutes.myOrdersPlaceholder),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.heart,
                    iconBackground: AppColors.accent,
                    label: AppStrings.menuWishlist,
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.clock,
                    iconBackground: AppColors.primary,
                    label: AppStrings.menuRecentlyViewed,
                    onTap: () => context.push(AppRoutes.recentlyViewed),
                  ),
                  ProfileMenuTile(
                    icon: LucideIcons.star,
                    iconBackground: AppColors.success,
                    label: AppStrings.menuMyReviews,
                    onTap: () => context.push(AppRoutes.myReviews),
                  ),
                ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: AppStrings.sectionAccountSettings,
          children: [
            ProfileMenuTile(
              icon: LucideIcons.user,
              iconBackground: AppColors.warning,
              label: AppStrings.menuPersonalInfo,
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
            ProfileMenuTile(
              icon: LucideIcons.lock,
              iconBackground: context.textSecondary,
              label: AppStrings.menuChangePassword,
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            ProfileMenuTile(
              icon: LucideIcons.bell,
              iconBackground: AppColors.accent,
              label: AppStrings.menuNotificationsSettings,
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            ProfileMenuTile(
              icon: LucideIcons.globe,
              iconBackground: AppColors.primary,
              label: AppStrings.menuLanguage,
              onTap: () => _languageSheet(context, ref),
            ),
            ProfileMenuTile(
              icon: LucideIcons.creditCard,
              iconBackground: AppColors.success,
              label: AppStrings.menuPaymentMethods,
              onTap: () => context.push(AppRoutes.paymentMethods),
            ),
            ProfileMenuTile(
              icon: LucideIcons.mapPin,
              iconBackground: AppColors.error,
              label: AppStrings.menuAddresses,
              onTap: () => context.push(AppRoutes.addresses),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: AppStrings.sectionPreferences,
          children: [
            const ThemeToggleTile(),
            ProfileSwitchTile(
              icon: LucideIcons.bellOff,
              iconBackground: context.textSecondary,
              label: AppStrings.menuPushNotifications,
              value: push,
              onChanged: ref.read(profileNotifierProvider.notifier).togglePushNotifications,
            ),
            ProfileSwitchTile(
              icon: LucideIcons.mail,
              iconBackground: AppColors.primary,
              label: AppStrings.menuEmailUpdates,
              value: email,
              onChanged: ref.read(profileNotifierProvider.notifier).toggleEmailUpdates,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        ProfileMenuSection(
          title: AppStrings.sectionSupport,
          children: [
            ProfileMenuTile(
              icon: LucideIcons.messageCircle,
              iconBackground: AppColors.primary,
              label: AppStrings.menuHelpCenter,
              onTap: () => context.push(AppRoutes.help),
            ),
            ProfileMenuTile(
              icon: LucideIcons.fileText,
              iconBackground: context.textSecondary,
              label: AppStrings.menuTerms,
              onTap: () => context.push(AppRoutes.terms),
            ),
            ProfileMenuTile(
              icon: LucideIcons.shield,
              iconBackground: AppColors.success,
              label: AppStrings.menuPrivacy,
              onTap: () => context.push(AppRoutes.privacy),
            ),
            ProfileMenuTile(
              icon: LucideIcons.star,
              iconBackground: AppColors.warning,
              label: AppStrings.menuRateApp,
              onTap: () => _rateApp(context),
            ),
            ProfileMenuTile(
              icon: LucideIcons.share2,
              iconBackground: AppColors.accent,
              label: AppStrings.menuShareApp,
              onTap: _shareApp,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        Text(
          AppStrings.sectionDangerZone,
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
          child: Text(AppStrings.logOut),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: () => _deleteAccount(context, ref),
            child: Text(
              AppStrings.deleteAccount,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),
        Center(
          child: Text(
            AppStrings.profileFooterLine,
            style: AppTypography.labelSmall.copyWith(color: context.textDisabled),
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
      ],
    );
  }
}
