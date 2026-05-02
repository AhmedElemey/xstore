import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    this.titleForSemantics,
    required this.imageUrls,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.listingId,
    this.bottomInset = 0,
  });

  /// Used only for accessibility (image semantic labels).
  final String? titleForSemantics;

  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final String listingId;
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

  String _listingLabel(BuildContext context) {
    final t = widget.titleForSemantics?.trim();
    if (t != null && t.isNotEmpty) return t;
    return context.l10n.productScreenTitle;
  }

  String _photoLabel(BuildContext context, int index, int total) =>
      '${_listingLabel(context)} · ${context.l10n.listingPhotoSectionTitle} '
      '${index + 1} / $total';

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return ColoredBox(
        color: context.textDisabled,
        child: Center(
          child: Icon(
            LucideIcons.imageOff,
            size: AppSpacing.x4l,
            color: context.textSecondary,
          ),
        ),
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
              child: Semantics(
                image: true,
                label: _photoLabel(context, i, urls.length),
                child: CachedNetworkImage(
                  imageUrl: urls[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: context.textDisabled,
                    child: Icon(
                      LucideIcons.imageOff,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
          right: AppSpacing.x3l + AppSpacing.x2l,
          child: WishHeartButton(
            listingId: widget.listingId,
            size: 22,
            onDarkBackground: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.bottomInset + AppSpacing.sm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == widget.selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    width: active ? AppSpacing.xl : AppSpacing.sm,
                    height: AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: active
                          ? context.surfaceColor
                          : context.surfaceColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                  );
                }),
              ),
              const Gap(AppSpacing.sm),
              SizedBox(
                height: AppSpacing.x4l + AppSpacing.xs,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: urls.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final sel = i == widget.selectedIndex;
                    return Semantics(
                      button: true,
                      label:
                          '${_photoLabel(context, i, urls.length)} · thumbnail',
                      child: GestureDetector(
                        onTap: () => widget.onPageChanged(i),
                        child: Container(
                          width: AppSpacing.x4l,
                          height: AppSpacing.x4l,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm),
                            border: Border.all(
                              color: sel
                                  ? context.surfaceColor
                                  : context.surfaceColor.withValues(alpha: 0.35),
                              width:
                                  sel ? AppSpacing.xs / 2 : AppSpacing.xs / 4,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Semantics(
                            image: true,
                            label: _photoLabel(context, i, urls.length),
                            child: CachedNetworkImage(
                              imageUrl: urls[i],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Icon(LucideIcons.imageOff),
                            ),
                          ),
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
