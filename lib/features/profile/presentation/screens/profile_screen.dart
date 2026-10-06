import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_blocks.dart';
import '../widgets/profile_sheets.dart';
import '../widgets/profile_sliver_app_bar.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_verification_banner.dart';
import '../widgets/vendor_store_card.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/skeletons/profile_skeleton.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// Tab bodies end above the floating dock (see `home_screen.dart`).
  static const double _dockClearance = 124;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureProfileLoaded();
    });
  }

  /// Cold-start prefetch covers the normal path; this only runs when profile
  /// state is still empty and no fetch is in flight (prefetch missed/reset).
  void _ensureProfileLoaded() {
    final s = ref.read(profileNotifierProvider);
    if (s.profile == null && !s.isLoading && s.error == null) {
      unawaited(
        ref.read(profileNotifierProvider.notifier).refreshProfileData(),
      );
    }
  }

  /// Full-page error only when enriched profile failed and auth has no identity
  /// to render (token-only stub). After login/restore, auth already carries the
  /// user from get-profile — show the tab with an inline retry banner instead.
  bool _showFullPageProfileError(UserEntity user, ProfileState profileState) {
    return profileState.error != null &&
        profileState.profile == null &&
        user.id.isEmpty;
  }

  Future<void> _onRefresh() async {
    await ref
        .read(profileNotifierProvider.notifier)
        .refreshProfileData(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final user = auth.valueOrNull;
    final profile = profileState.profile;

    if (user == null) {
      return const Scaffold(body: ProfileSkeleton());
    }

    final u = profile?.user ?? user;
    final isVendor = u.hasStore;
    final phoneMissing = AppValidators.isMissingPhoneNumber(u.phoneNumber);

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.profile,
      onReentry: (ref) =>
          ref.read(profileNotifierProvider.notifier).refreshProfileData(),
      child: Scaffold(
        body: OrbitBackground(
          child: RefreshIndicator(
            color: context.linkColor,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const ProfileSliverAppBar(),
                if (profileState.isLoading && profile == null)
                  const SliverFillRemaining(child: ProfileSkeleton())
                else if (_showFullPageProfileError(user, profileState))
                  SliverFillRemaining(
                    child: ErrorStateWidget(
                      message: resolveAppError(context, profileState.error),
                      onRetry: _onRefresh,
                    ),
                  )
                else ...[
                  if (profileState.error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.md,
                        ),
                        child: Material(
                          color: context.glassColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(
                              color: context.colorScheme.error.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.error_outline,
                              color: context.colorScheme.error,
                            ),
                            title: Text(
                              resolveAppError(context, profileState.error),
                              style: TextStyle(color: context.textPrimary),
                            ),
                            trailing: TextButton(
                              onPressed: _onRefresh,
                              child: Text(context.l10n.retry),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      user: u,
                      avatarFile: profileState.editAvatarFile,
                      onEditProfile: () => context.push(AppRoutes.profileEdit),
                    ),
                  ),
                  if (profile != null &&
                      ((!profile.isEmailVerified && u.email.isNotEmpty) ||
                          phoneMissing ||
                          !profile.isPhoneVerified))
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.xl,
                          0,
                        ),
                        child: ProfileVerificationBanner(
                          email: u.email,
                          phoneNumber: u.phoneNumber,
                          showEmailPrompt:
                              !profile.isEmailVerified && u.email.isNotEmpty,
                          showPhonePrompt:
                              phoneMissing || !profile.isPhoneVerified,
                        ),
                      ),
                    ),
                  // Couriers have no orders/wishlist/saved-amount or vendor
                  // sales stats — ProfileStatsRow only branches vendor vs.
                  // everything-else, so without this gate a courier would see
                  // consumer stats (always 0) whose taps push routes blocked by
                  // the courier route guard. Delivery-specific stats (deliveries
                  // count, cash wallet balance) belong in the delivery module,
                  // out of scope here — omit the row entirely for now.
                  if (!user.isCourier)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.xl,
                          0,
                        ),
                        child: ProfileStatsRow(
                          role: isVendor ? UserRole.vendor : user.role,
                          sales: profile?.user.totalSales,
                          rating: profile?.user.rating,
                          responsePercent: profile?.responseRatePercent,
                          // The profile endpoint has no orders count; use the orders
                          // list when it has fully loaded (one page = not a count).
                          orders: isVendor
                              ? null
                              : ref.watch(
                                  ordersNotifierProvider.select(
                                    (s) =>
                                        s.hasMore ||
                                            s.isLoading ||
                                            s.error != null
                                        ? null
                                        : s.orders.length,
                                  ),
                                ),
                          // getProfile has no confirmed backend source for this
                          // yet (defaults to 0), but the wishlist endpoint is
                          // live and wishlistProvider already keeps itself in
                          // sync via its own authProvider listener — read the
                          // real count from there instead of the profile stub.
                          wishlistCount: ref.watch(
                            wishlistProvider.select((s) => s.itemCount),
                          ),
                          savedDzd: profile?.savedAmountDzd,
                          onSalesTap: () => context.go(AppRoutes.listingMy),
                          onOrdersTap: () => context.go(
                            isVendor
                                ? AppRoutes.vendorOrders
                                : AppRoutes.orders,
                          ),
                          onWishlistTap: () => context.go(AppRoutes.wishlist),
                        ),
                      ),
                    ),
                  if (isVendor && profile != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: VendorStoreCard(profile: profile),
                      ),
                    ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      0,
                    ),
                    child: ProfileMenuBlocks(
                      isVendor: isVendor,
                      isCourier: user.isCourier,
                      onLogout: () =>
                          showProfileLogoutSheet(context: context, ref: ref),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: _dockClearance),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
