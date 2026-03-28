import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/banner_entity.dart';

class HeroBannerCarousel extends StatelessWidget {
  const HeroBannerCarousel({
    super.key,
    required this.banners,
  });

  final List<BannerEntity> banners;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return CarouselSlider(
      options: CarouselOptions(
        height: AppSpacing.x4l * 3 + AppSpacing.x3l + AppSpacing.sm,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: banners
          .map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: b.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: AppColors.textDisabled,
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.textDisabled,
                        child: Icon(LucideIcons.imageOff),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Text(
                        b.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.cardBg,
                              shadows: [
                                Shadow(
                                  blurRadius: AppSpacing.sm,
                                  color: AppColors.textPrimary.withValues(alpha: 0.45),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
