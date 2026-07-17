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
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_blocks.dart';
import '../widgets/profile_sheets.dart';
import '../widgets/profile_sliver_app_bar.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/vendor_store_card.dart';
import '../../../store/presentation/providers/store_hours_provider.dart';
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
      ref.read(storeHoursNotifierProvider.notifier).fetchStoreHours();
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
    await ref.read(profileNotifierProvider.notifier).refreshProfileData();
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

    final isVendor = user.role == UserRole.vendor;
    final u = profile?.user ?? user;

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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: ProfileStatsRow(
                    role: user.role,
                    sales: profile?.user.totalSales,
                    rating: profile?.user.rating,
                    responsePercent: profile?.responseRatePercent,
                    orders: profile?.ordersCount,
                    wishlistCount: profile?.wishlistCount,
                    savedDzd: profile?.savedAmountDzd,
                    onSalesTap: () => context.push(AppRoutes.listingMy),
                    onRatingTap: () => context.push(AppRoutes.analytics),
                    onResponseTap: () => context.push(AppRoutes.earnings),
                    onOrdersTap: () => context.push(
                      isVendor ? AppRoutes.vendorOrders : AppRoutes.orders,
                    ),
                    onWishlistTap: () => context.push(AppRoutes.wishlist),
                    onSavedTap: () => context.push(AppRoutes.earnings),
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
                      onManageStore: () => context.push(
                        '${AppRoutes.sellerProfile}/${u.id}',
                      ),
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
