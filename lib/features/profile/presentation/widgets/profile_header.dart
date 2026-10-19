import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.avatarFile,
    this.onEditProfile,
  });

  final UserEntity user;

  /// Locally picked avatar that hasn't been saved yet; wins over the URL.
  final File? avatarFile;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final cityLine = user.location ?? user.storeCity ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarOrb(
                name: user.name,
                avatarUrl: user.avatarUrl,
                avatarFile: avatarFile,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.verified,
                            color: context.linkColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                    if (cityLine.isNotEmpty) ...[
                      const Gap(AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: AppSpacing.md,
                            color: context.iconSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              cityLine,
                              style: AppTypography.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          OutlinedButton(
            onPressed: onEditProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.linkColor,
              backgroundColor: context.glassColor,
              side: BorderSide(color: context.borderColor),
              minimumSize: const Size.fromHeight(44),
              shape: const StadiumBorder(),
            ),
            child: Text(
              context.l10n.editProfile,
              style: AppTypography.body12.copyWith(
                color: context.linkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand-gradient orb: the avatar photo when there is one, else initials.
class _AvatarOrb extends StatelessWidget {
  const _AvatarOrb({required this.name, this.avatarUrl, this.avatarFile});

  static const double _size = 72;

  final String name;
  final String? avatarUrl;
  final File? avatarFile;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    final Widget child;
    if (avatarFile != null) {
      child = Image.file(
        avatarFile!,
        fit: BoxFit.cover,
        cacheWidth: (_size * 3).round(),
      );
    } else if (url != null && url.isNotEmpty) {
      child = AppCachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: (_size * 3).round(),
        memCacheHeight: (_size * 3).round(),
        placeholder: (_, __) => _initials(context),
        errorWidget: (_, __, ___) => _initials(context),
      );
    } else {
      child = _initials(context);
    }

    return Semantics(
      image: true,
      label: '${context.l10n.navProfile}: $name',
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.brandGradient,
          ),
          border: Border.all(color: context.borderColor, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget _initials(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final initials = parts.take(2).map((e) => e[0].toUpperCase()).join();
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTypography.headlineSmall.copyWith(
          fontSize: 24,
          color: context.onBrandColor,
        ),
      ),
    );
  }
}
