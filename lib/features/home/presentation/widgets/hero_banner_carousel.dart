import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

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
        height: 180,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: banners
          .map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: b.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFFE2E8F0),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFE2E8F0),
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Text(
                        b.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
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
