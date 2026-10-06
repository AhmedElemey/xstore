import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';

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
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(diameter * 0.1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: context.brandGradient),
                  ),
                  child: Icon(
                    LucideIcons.camera,
                    size: diameter * 0.16,
                    color: context.onBrandColor,
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
        child: AppCachedNetworkImage(
          imageUrl: imageUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          memCacheWidth: (diameter * 3).round(),
          memCacheHeight: (diameter * 3).round(),
          placeholder: (_, __) =>
              _InitialsAvatar(name: name, diameter: diameter),
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

    // The glow sits on the opaque orb itself, so it never tints a glass fill.
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.brandGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: context.brandGradient.first.withValues(alpha: 0.35),
            blurRadius: 28,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.headlineSmall.copyWith(
          color: context.onBrandColor,
          fontSize: diameter * 0.24,
        ),
      ),
    );
  }
}
