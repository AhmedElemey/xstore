import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.imageUrls,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.bottomInset = 0,
  });

  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final double bottomInset;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(ProductImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFE2E8F0),
        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 48)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: urls.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (context, i) {
            return InteractiveViewer(
              panEnabled: false,
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE2E8F0),
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 56,
          child: Material(
            color: Colors.black38,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              iconSize: 22,
              color: Colors.white,
              onPressed: widget.onToggleFavorite,
              icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.bottomInset + 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == widget.selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Gap(AppSpacing.xs),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: urls.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final sel = i == widget.selectedIndex;
                    return GestureDetector(
                      onTap: () => widget.onPageChanged(i),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sel ? Colors.white : Colors.white24,
                            width: sel ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: urls[i],
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(Icons.image),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
