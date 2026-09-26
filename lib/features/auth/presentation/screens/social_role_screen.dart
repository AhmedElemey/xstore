import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/social_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/role_selector_card.dart';
import '../../../../shared/widgets/space_background.dart';

/// Account type for a new social sign-in (Google today; Apple/Facebook are
/// parked). Picking a type registers and logs in, then the router goes home.
class SocialRoleScreen extends ConsumerStatefulWidget {
  const SocialRoleScreen({super.key});

  @override
  ConsumerState<SocialRoleScreen> createState() => _SocialRoleScreenState();
}

class _SocialRoleScreenState extends ConsumerState<SocialRoleScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    ref.listen(socialAuthProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error && mounted) {
        AppSnackbar.error(context, next.error!);
      }
    });
    final social = ref.watch(socialAuthProvider);
    final pending = social.pendingSocialResult;
    void cancel() {
      ref.read(socialAuthProvider.notifier).cancelSocialRegistration();
      context.go(AppRoutes.login);
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
          child: Center(
            child: OrbitCircleButton(
              tooltip: context.l10n.cancel,
              onPressed: social.isAnyLoading ? null : cancel,
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? LucideIcons.chevronRight
                    : LucideIcons.chevronLeft,
                size: 22,
                color: context.textPrimary,
              ),
            ),
          ),
        ),
      ),
      body: SpaceBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, AppSpacing.sm, 24, 28),
            children: [
              if (pending != null) ...[
                _AccountChip(result: pending),
                const Gap(AppSpacing.xl),
              ],
              AuthHeader(
                title: context.l10n.chooseYourRole,
                subtitle: context.l10n.socialRoleSubtitle,
              ),
              const Gap(AppSpacing.xl),
              RoleSelectorCard(
                title: context.l10n.iAmBuyer,
                subtitle: context.l10n.buyerSubtitle,
                icon: LucideIcons.shoppingBag,
                paletteIndex: 0,
                isSelected: _selectedRole == UserRole.consumer,
                onTap: () => setState(() => _selectedRole = UserRole.consumer),
              ),
              const Gap(AppSpacing.md),
              RoleSelectorCard(
                title: context.l10n.iAmSeller,
                subtitle: context.l10n.sellerSubtitle,
                icon: LucideIcons.store,
                paletteIndex: 3,
                isSelected: _selectedRole == UserRole.vendor,
                onTap: () => setState(() => _selectedRole = UserRole.vendor),
              ),
              const Gap(AppSpacing.x3l),
              XstoreButton(
                label: context.l10n.continueLabel,
                isLoading: social.isAnyLoading,
                onPressed: _selectedRole == null || social.isAnyLoading
                    ? null
                    : () => ref
                        .read(socialAuthProvider.notifier)
                        .completeSocialRegistration(_selectedRole!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The signed-in social account: avatar orb, name and "email · Provider".
class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.result});

  final SocialAuthResult result;

  @override
  Widget build(BuildContext context) {
    final name = (result.displayName ?? '').trim();
    final photo = (result.photoUrl ?? '').trim();
    final provider = switch (result.provider) {
      SocialProvider.google => 'Google',
      SocialProvider.facebook => 'Facebook',
      SocialProvider.apple => 'Apple',
    };
    final email = (result.email ?? '').trim();
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: orbitOrbGradient(3),
            ),
            child: photo.isNotEmpty
                ? AppCachedNetworkImage(
                    imageUrl: photo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    memCacheWidth: 120,
                    memCacheHeight: 120,
                  )
                : Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.space,
                    ),
                  ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? context.l10n.socialWelcomeFallbackName : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  email.isEmpty ? provider : '$email · $provider',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
