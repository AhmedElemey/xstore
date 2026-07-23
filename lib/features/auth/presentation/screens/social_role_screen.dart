import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/social_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/role_selector_card.dart';

class SocialRoleScreen extends ConsumerStatefulWidget {
  const SocialRoleScreen({super.key});

  @override
  ConsumerState<SocialRoleScreen> createState() => _SocialRoleScreenState();
}

class _SocialRoleScreenState extends ConsumerState<SocialRoleScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final social = ref.watch(socialAuthProvider);
    final pending = social.pendingSocialResult;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 42,
            child: AuthHeader(
              heightFraction: 1,
              title: context.l10n.chooseYourRole,
              subtitle: context.l10n.socialRoleSubtitle,
              logoSize: 32,
            ),
          ),
          Expanded(
            flex: 58,
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  children: [
                    Center(
                      child: Transform.translate(
                        offset: const Offset(0, -8),
                        child: _SocialWelcomeAvatar(
                          displayName: pending?.displayName,
                          photoUrl: pending?.photoUrl,
                          provider: pending?.provider,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.spacing10),
                    Text(
                      'Welcome, ${pending?.displayName ?? 'there'}! 👋',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      'One last step — how will you use xStore?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSecondary),
                    ),
                    const Gap(AppSpacing.spacing18),
                    RoleSelectorCard(
                      title: "I'm a Buyer",
                      subtitle: 'Discover and buy products from verified sellers',
                      icon: Icons.shopping_bag_outlined,
                      accentColor: AppColors.primary,
                      selectionBorderColor: AppColors.primary,
                      isSelected: _selectedRole == UserRole.consumer,
                      onTap: () => setState(() => _selectedRole = UserRole.consumer),
                      features: const [
                        'Browse thousands of products',
                        'Secure checkout & payments',
                      ],
                    ),
                    RoleSelectorCard(
                      title: "I'm a Seller",
                      subtitle: 'List products and start earning today',
                      icon: Icons.storefront_outlined,
                      accentColor: AppColors.accent,
                      selectionBorderColor: AppColors.accent,
                      isSelected: _selectedRole == UserRole.vendor,
                      onTap: () => setState(() => _selectedRole = UserRole.vendor),
                      features: const [
                        'List unlimited products',
                        'Manage orders & inventory',
                      ],
                    ),
                    const Gap(AppSpacing.md),
                    XstoreButton(
                      label: 'Continue',
                      isLoading: social.isAnyLoading,
                      onPressed: _selectedRole == null || social.isAnyLoading
                          ? null
                          : () => ref
                              .read(socialAuthProvider.notifier)
                              .completeSocialRegistration(_selectedRole!),
                    ),
                    const Gap(AppSpacing.sm),
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
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  static const _diameter = 96.0;
  static const _ringWidth = 3.0;

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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.profileHeaderGradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(_ringWidth),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surfaceColor,
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
        ),
        if (provider != null)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _SocialProviderBadge(provider: provider!),
            ),
          ),
      ],
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.displayName,
    required this.diameter,
  });

  final String? displayName;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final parts =
        (displayName ?? '').trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final initials = parts
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();
    final label = initials.isEmpty ? '?' : initials;

    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: diameter * 0.32,
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
          width: 20,
          height: 20,
        ),
      SocialProvider.facebook => SvgPicture.asset(
          'assets/icons/facebook_logo.svg',
          width: 20,
          height: 20,
        ),
      SocialProvider.apple => Icon(
          Icons.apple,
          size: 22,
          color: context.isDark ? AppColors.white : AppColors.black,
        ),
    };
  }
}
