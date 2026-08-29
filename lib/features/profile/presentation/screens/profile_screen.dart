import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
// TODO(phase-2): Re-enable once store/active hours ships.
// import '../../../store/presentation/providers/store_hours_provider.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeletons/profile_skeleton.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureProfileLoaded();
      // TODO(phase-2): Store/active hours deferred to next phase.
      // ref.read(storeHoursNotifierProvider.notifier).fetchStoreHours();
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

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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
    final sellerId = u.id.isNotEmpty ? u.id : user.id;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          slivers: [
            ProfileSliverAppBar(
              scrollController: _scroll,
              userName: u.name,
              avatarUrl: u.avatarUrl,
              avatarFile: profileState.editAvatarFile,
            ),
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
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Material(
                      color: context.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(
                          Icons.error_outline,
                          color: context.colorScheme.onErrorContainer,
                        ),
                        title: Text(
                          resolveAppError(context, profileState.error),
                          style: TextStyle(
                            color: context.colorScheme.onErrorContainer,
                          ),
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
                child: Transform.translate(
                  offset: const Offset(0, -AppSpacing.profileAvatarHalfOut),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: ProfileHeader(
                      user: u,
                      avatarFile: profileState.editAvatarFile,
                      onEditProfile: () => context.push(AppRoutes.profileEdit),
                      onAvatarTap: () => showProfileAvatarPickerSheet(
                        context: context,
                        ref: ref,
                      ),
                    ),
                  ),
                ),
              ),
              if (profile != null &&
                  (profile.isEmailVerificationRequired ||
                      profile.isPhoneVerificationRequired))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: ProfileVerificationBanner(
                      email: u.email,
                      phoneNumber: u.phoneNumber,
                      showEmailPrompt: profile.isEmailVerificationRequired,
                      showPhonePrompt: profile.isPhoneVerificationRequired,
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
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: ProfileStatsRow(
                      role: isVendor ? UserRole.vendor : user.role,
                      sales: profile?.user.totalSales,
                      rating: profile?.user.rating,
                      responsePercent: profile?.responseRatePercent,
                      orders: profile?.ordersCount,
                      // getProfile has no confirmed backend source for this
                      // yet (defaults to 0), but the wishlist endpoint is
                      // live and wishlistProvider already keeps itself in
                      // sync via its own authProvider listener — read the
                      // real count from there instead of the profile stub.
                      wishlistCount:
                          ref.watch(wishlistProvider.select((s) => s.itemCount)),
                      savedDzd: profile?.savedAmountDzd,
                      onSalesTap: () => context.go(AppRoutes.listingMy),
                      onOrdersTap: () => context.go(
                        isVendor ? AppRoutes.vendorOrders : AppRoutes.orders,
                      ),
                      onWishlistTap: () => context.go(AppRoutes.wishlist),
                    ),
                  ),
                ),
              if (isVendor && profile != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                    ),
                    child: VendorStoreCard(
                      profile: profile,
                      onManageStore: sellerId.isEmpty
                          ? null
                          : () => context.push(AppRoutes.sellerPath(sellerId)),
                    ),
                  ),
                ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ProfileMenuBlocks(
                  isVendor: isVendor,
                  isCourier: user.isCourier,
                  onLogout: () => showProfileLogoutSheet(context: context, ref: ref),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}
