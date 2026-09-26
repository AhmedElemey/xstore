import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Orbit profile card: ringed avatar orb, name, phone, Edit, and badges for
/// the verified contact details.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.emailVerified,
    required this.phoneVerified,
    this.avatarFile,
    this.onEditProfile,
    this.onAvatarTap,
  });

  final UserEntity user;
  final bool emailVerified;
  final bool phoneVerified;
  final File? avatarFile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    final phone = AppValidators.isMissingPhoneNumber(user.phoneNumber)
        ? user.email
        : '+20 ${AppValidators.formatEgyptPhone(AppValidators.toE164Egypt(user.phoneNumber))}';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            AppColors.nova.withValues(alpha: 0.14),
            context.cashColor.withValues(alpha: 0.08),
          ],
          stops: const [0, 0.6, 1],
        ),
        border: Border.all(color: context.borderColor),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -40,
            end: -40,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: _Avatar(
                        name: user.name,
                        url: user.avatarUrl,
                        file: avatarFile,
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              fontFamily: AppTypography.displayFontFamily,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          const Gap(AppSpacing.xs),
                          Text(
                            phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onEditProfile,
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(
                        context.l10n.profileEdit,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (emailVerified || phoneVerified) ...[
                  const Gap(14),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (emailVerified)
                        _Badge(context.l10n.profileEmailVerifiedBadge),
                      if (phoneVerified)
                        _Badge(context.l10n.profilePhoneVerifiedBadge),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.url, required this.file});

  final String name;
  final String? url;
  final File? file;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cache = (size * dpr).round();
    final Widget? image = file != null
        ? Image.file(
            file!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: cache,
          )
        : (url != null && url!.isNotEmpty)
            ? AppCachedNetworkImage(
                imageUrl: url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                memCacheWidth: cache,
                memCacheHeight: cache,
              )
            : null;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: orbitOrbGradient(1),
        boxShadow: [
          BoxShadow(color: context.backgroundColor, spreadRadius: 4),
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.5),
            spreadRadius: 5,
          ),
        ],
      ),
      child: image ??
          Text(
            name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.space,
            ),
          ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.success,
        ),
      ),
    );
  }
}
