import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WishlistPriceDropBanner extends ConsumerWidget {
  const WishlistPriceDropBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerState = ref.watch(
      wishlistProvider.select(
        (s) => (
          dropCount: s.priceDropCount,
          visible: s.isPriceDropBannerVisible,
        ),
      ),
    );
    final dropCount = bannerState.dropCount;
    if (dropCount <= 0 || !bannerState.visible) {
      return const SizedBox.shrink();
    }

    return KeyedSubtree(
      key: ValueKey<int>(dropCount),
      child: _WishlistPriceDropBannerSlide(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            elevation: 2,
            shadowColor: context.textPrimary.withValues(alpha: 0.08),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.95),
                    AppColors.success.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.x4l + AppSpacing.sm,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.wishlistPriceDropBanner(dropCount),
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppStrings.wishlistPriceDropBannerSubtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => ref
                              .read(wishlistProvider.notifier)
                              .showPriceDropsFilter(),
                          child: Text(
                            AppStrings.wishlistViewPriceDrops,
                            style: AppTypography.labelLarge.copyWith(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: IconButton(
                      onPressed: () => ref
                          .read(wishlistProvider.notifier)
                          .dismissPriceDropBanner(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.white,
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistPriceDropBannerSlide extends StatefulWidget {
  const _WishlistPriceDropBannerSlide({required this.child});

  final Widget child;

  @override
  State<_WishlistPriceDropBannerSlide> createState() =>
      _WishlistPriceDropBannerSlideState();
}

class _WishlistPriceDropBannerSlideState extends State<_WishlistPriceDropBannerSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offset, child: widget.child);
  }
}
