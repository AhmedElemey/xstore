import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/social_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/role_selector_card.dart';

// TODO(phase-2): Apple and Facebook sign-in are parked (no buttons render); keep for restore.
// Only Apple/Facebook reach this screen (Google is login-only).
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
    final l10n = context.l10n;
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  children: [
                    // Who is signing up: avatar, greeting, last-step note.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: context.glassColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          _SocialWelcomeAvatar(
                            displayName: pending?.displayName,
                            photoUrl: pending?.photoUrl,
                            provider: pending?.provider,
                          ),
                          const Gap(AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.socialWelcomeGreeting(
                                    pending?.displayName ??
                                        l10n.socialWelcomeFallbackName,
                                  ),
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  l10n.socialRoleLastStep,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.labelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.x2l),
                    Text(
                      l10n.chooseYourRole,
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const Gap(AppSpacing.spacing10),
                    Text(
                      l10n.socialRoleSubtitle,
                      style: AppTypography.body15.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const Gap(AppSpacing.xl),
                    RoleSelectorCard(
                      title: l10n.iAmBuyer,
                      subtitle: l10n.buyerSubtitle,
                      icon: LucideIcons.shoppingBag,
                      orbColors: const [
                        AppColors.white,
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                      isSelected: _selectedRole == UserRole.consumer,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.consumer),
                      features: [l10n.buyerFeature1, l10n.buyerFeature2],
                    ),
                    RoleSelectorCard(
                      title: l10n.iAmSeller,
                      subtitle: l10n.sellerSubtitle,
                      icon: LucideIcons.store,
                      orbColors: const [
                        AppColors.white,
                        AppColors.accentLight,
                        AppColors.darkSecondary,
                      ],
                      isSelected: _selectedRole == UserRole.vendor,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.vendor),
                      features: [l10n.sellerFeature1, l10n.sellerFeature2],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, AppSpacing.md, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    XstoreButton(
                      label: l10n.continueLabel,
                      isLoading: social.isAnyLoading,
                      onPressed: _selectedRole == null || social.isAnyLoading
                          ? null
                          : () => ref
                                .read(socialAuthProvider.notifier)
                                .completeSocialRegistration(_selectedRole!),
                    ),
                    const Gap(AppSpacing.xs),
                    Center(
                      child: TextButton(
                        onPressed: social.isAnyLoading
                            ? null
                            : () {
                                ref
                                    .read(socialAuthProvider.notifier)
                                    .cancelSocialRegistration();
                                context.go(AppRoutes.login);
                              },
                        child: Text(
                          l10n.cancel,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.linkColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialWelcomeAvatar extends StatelessWidget {
  const _SocialWelcomeAvatar({
    required this.displayName,
    required this.photoUrl,
    required this.provider,
  });

  static const _diameter = 40.0;
  static const _ringWidth = 2.0;

  final String? displayName;
  final String? photoUrl;
  final SocialProvider? provider;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (_diameter * dpr).round();
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: context.brandGradient),
          ),
          padding: const EdgeInsets.all(_ringWidth),
          child: ClipOval(
            child: SizedBox(
              width: _diameter,
              height: _diameter,
              child: hasPhoto
                  ? AppCachedNetworkImage(
                      imageUrl: photoUrl!,
                      width: _diameter,
                      height: _diameter,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheSize,
                      memCacheHeight: cacheSize,
                      placeholder: (_, __) => _InitialsFallback(
                        displayName: displayName,
                        diameter: _diameter,
                      ),
                      errorWidget: (_, __, ___) => _InitialsFallback(
                        displayName: displayName,
                        diameter: _diameter,
                      ),
                    )
                  : _InitialsFallback(
                      displayName: displayName,
                      diameter: _diameter,
                    ),
            ),
          ),
        ),
        if (provider != null)
          PositionedDirectional(
            end: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: context.elevatedSurfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: _SocialProviderBadge(provider: provider!),
            ),
          ),
      ],
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.displayName, required this.diameter});

  final String? displayName;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final parts = (displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty);
    final initials = parts
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();
    final label = initials.isEmpty ? '?' : initials;

    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [
            AppColors.white,
            AppColors.accentLight,
            AppColors.darkSecondary,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.darkBackground,
          fontWeight: FontWeight.w800,
          fontSize: diameter * 0.4,
        ),
      ),
    );
  }
}

class _SocialProviderBadge extends StatelessWidget {
  const _SocialProviderBadge({required this.provider});

  final SocialProvider provider;

  @override
  Widget build(BuildContext context) {
    return switch (provider) {
      SocialProvider.google => SvgPicture.asset(
        'assets/icons/google_logo.svg',
        width: 12,
        height: 12,
      ),
      SocialProvider.facebook => SvgPicture.asset(
        'assets/icons/facebook_logo.svg',
        width: 12,
        height: 12,
      ),
      SocialProvider.apple => Icon(
        Icons.apple,
        size: 14,
        color: context.isDark ? AppColors.white : AppColors.black,
      ),
    };
  }
}
