import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.avatarFile,
    this.onEditProfile,
    this.onAvatarTap,
  });

  final UserEntity user;
  final File? avatarFile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final cityLine = user.location ?? user.storeCity ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.x4l + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Transform.translate(
          //   offset: const Offset(0, -AppSpacing.x4l - AppSpacing.sm),
          //   child: ProfileAvatarPicker(
          //     name: user.name,
          //     imageUrl: user.avatarUrl,
          //     imageFile: avatarFile,
          //     onTap: onAvatarTap,
          //   ),
          // ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ],
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      user.email,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                    if (cityLine.isNotEmpty) ...[
                      const Gap(AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: onEditProfile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  context.l10n.editProfile,
                  style: AppTypography.body12.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
