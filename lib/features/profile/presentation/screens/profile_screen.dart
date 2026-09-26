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
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_blocks.dart';
import '../widgets/profile_sheets.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_verification_banner.dart';
import '../widgets/vendor_store_card.dart';
// TODO(phase-2): Re-enable once store/active hours ships.
// import '../../../store/presentation/providers/store_hours_provider.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/skeletons/profile_skeleton.dart';
import '../../../../shared/widgets/space_background.dart';

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
    final phoneMissing = AppValidators.isMissingPhoneNumber(u.phoneNumber);
    // final sellerId = u.id.isNotEmpty ? u.id : user.id;

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.profile,
      onReentry: (ref) =>
          ref.read(profileNotifierProvider.notifier).refreshProfileData(),
      child: Scaffold(
      backgroundColor: context.backgroundColor,
      body: SpaceBackground(child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.paddingOf(context).top),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: ProfileHeader(
                    user: u,
                    emailVerified: profile?.isEmailVerified ?? false,
                    phoneVerified: !phoneMissing &&
                        (profile?.isPhoneVerified ?? false),
                    avatarFile: profileState.editAvatarFile,
                    onEditProfile: () => context.push(AppRoutes.profileEdit),
                    onAvatarTap: () => showProfileAvatarPickerSheet(
                      context: context,
                      ref: ref,
                    ),
                  ),
                ),
              ),
              if (profile != null &&
                  ((!profile.isEmailVerified && u.email.isNotEmpty) ||
                      phoneMissing ||
                      !profile.isPhoneVerified))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                                            AppSpacing.sm,

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
              // Sellers keep their sales stats and store card under the
              // header; shoppers see their counts on the menu rows instead.
              if (isVendor && profile != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: ProfileStatsRow(
                      sales: profile.user.totalSales,
                      rating: profile.user.rating,
                      responsePercent: profile.responseRatePercent,
                      onSalesTap: () => context.go(AppRoutes.listingMy),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: VendorStoreCard(profile: profile),
                  ),
                ),
              ],
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
      )),
      ),
    );
  }
}
