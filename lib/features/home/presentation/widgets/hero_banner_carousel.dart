import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_dot.dart';
import '../../domain/entities/banner_entity.dart';

class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({super.key, required this.banners});

  final List<BannerEntity> banners;

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  late final PageController _pageController = PageController(
    viewportFraction: 0.9,
  );
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HeroBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      if (_currentPage.value >= widget.banners.length) {
        _currentPage.value = 0;
      }
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.banners.length <= 1) {
      return;
    }
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || widget.banners.isEmpty) {
        return;
      }
      final nextPage = (_currentPage.value + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }
    final bannerHeight = AppSpacing.x4l * 3 + AppSpacing.x3l + AppSpacing.sm;
    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) => _currentPage.value = index,
            itemBuilder: (context, index) {
              final b = widget.banners[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  var scale = 0.94;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    final page = _pageController.page ?? index.toDouble();
                    final delta = (page - index).abs().clamp(0.0, 1.0);
                    scale = 1 - (delta * 0.06);
                  } else if (_currentPage.value == index) {
                    scale = 1;
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppCachedNetworkImage(
                          imageUrl: b.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              ColoredBox(color: context.textDisabled),
                          errorWidget: (_, __, ___) => ColoredBox(
                            color: context.textDisabled,
                            child: Icon(
                              LucideIcons.imageOff,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.lg,
                          bottom: AppSpacing.lg,
                          child: Text(
                            b.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  
                                  shadows: [
                                    Shadow(
                                      blurRadius: AppSpacing.sm,
                                      color: context.textPrimary.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, activeIndex, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(widget.banners.length, (index) {
                  final isActive = index == activeIndex;
                  final activeColor = Theme.of(context).colorScheme.primary;
                  final inactiveColor = context.textDisabled;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: isActive
                        ? PulsingDot(
                            key: ValueKey<String>(widget.banners[index].id),
                            size: AppSpacing.sm + 2,
                            color: activeColor,
                          )
                        : Container(
                            key: ValueKey<String>(widget.banners[index].id),
                            width: AppSpacing.sm + 2,
                            height: AppSpacing.sm + 2,
                            decoration: BoxDecoration(
                              color: inactiveColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                  );
                }),
              );
            },
          ),
        ],
      ],
    );
  }
}
