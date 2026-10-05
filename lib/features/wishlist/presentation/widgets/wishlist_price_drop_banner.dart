import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/wishlist_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WishlistPriceDropBanner extends ConsumerWidget {
  const WishlistPriceDropBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerState = ref.watch(
      wishlistProvider.select(
        (s) =>
            (dropCount: s.priceDropCount, visible: s.isPriceDropBannerVisible),
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
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.45),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.x4l + AppSpacing.sm,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.wishlistPriceDropBanner(dropCount),
                        style: AppTypography.bodyLarge.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.wishlistPriceDropBannerSubtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: context.linkColor,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => ref
                            .read(wishlistProvider.notifier)
                            .showPriceDropsFilter(),
                        child: Text(
                          context.l10n.wishlistViewPriceDrops,
                          style: AppTypography.labelLarge.copyWith(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  top: AppSpacing.xs,
                  end: AppSpacing.xs,
                  child: IconButton(
                    onPressed: () => ref
                        .read(wishlistProvider.notifier)
                        .dismissPriceDropBanner(),
                    icon: const Icon(Icons.close_rounded),
                    color: context.labelColor,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                  ),
                ),
              ],
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

class _WishlistPriceDropBannerSlideState
    extends State<_WishlistPriceDropBannerSlide>
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
