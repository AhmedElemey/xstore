import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Circular avatar with optional camera badge; supports network URL, file, or initials fallback.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.name,
    this.imageUrl,
    this.imageFile,
    this.diameter = 90,
    this.showCameraBadge = true,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final File? imageFile;
  final double diameter;
  final bool showCameraBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _AvatarBody(
            name: name,
            imageUrl: imageUrl,
            imageFile: imageFile,
            diameter: diameter,
          ),
          if (showCameraBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.camera,
                    size: diameter * 0.16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarBody extends StatelessWidget {
  const _AvatarBody({
    required this.name,
    this.imageUrl,
    this.imageFile,
    required this.diameter,
  });

  final String name;
  final String? imageUrl;
  final File? imageFile;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return ClipOval(
        child: Image.file(
          imageFile!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
        ),
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          placeholder: (_, __) => _InitialsAvatar(name: name, diameter: diameter),
          errorWidget: (_, __, ___) =>
              _InitialsAvatar(name: name, diameter: diameter),
        ),
      );
    }
    return _InitialsAvatar(name: name, diameter: diameter);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.diameter});

  final String name;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final initials = parts
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();
    final label = initials.isEmpty ? '?' : initials;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.profileHeaderGradientEnd,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: diameter * 0.28,
        ),
      ),
    );
  }
}
