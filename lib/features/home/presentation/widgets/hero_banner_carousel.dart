import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/banner_entity.dart';

class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  final List<BannerEntity> banners;

  /// Called only for banners whose [BannerEntity.actionUrl] is non-empty.
  /// Live `/api/banners` currently omit that field — those stay inert.
  final void Function(String actionUrl)? onBannerTap;

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
              final actionUrl = b.actionUrl?.trim();
              final tappable = actionUrl != null && actionUrl.isNotEmpty;
              final card = DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: context.linkColor.withValues(alpha: 0.18),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedNetworkImage(
                        imageUrl: b.imageUrl,
                        fit: BoxFit.cover,
                        memCacheHeight: (bannerHeight * 3).round(),
                        placeholder: (_, __) =>
                            ColoredBox(color: context.glassColor),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: context.glassColor,
                          child: Icon(
                            LucideIcons.imageOff,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      // Scrim so the title stays legible on any picture.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00060818), Color(0xCC060818)],
                            stops: [0.45, 1],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: AppSpacing.lg,
                        end: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: Text(
                          b.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
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
                  child: tappable
                      ? GestureDetector(
                          key: ValueKey<String>('banner-action-${b.id}'),
                          onTap: () => widget.onBannerTap?.call(actionUrl),
                          child: card,
                        )
                      : card,
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs / 2,
                    ),
                    child: AnimatedContainer(
                      key: ValueKey<String>(widget.banners[index].id),
                      duration: const Duration(milliseconds: 220),
                      width: isActive ? 20 : AppSpacing.sm,
                      height: AppSpacing.sm,
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.linkColor
                            : context.labelColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
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
