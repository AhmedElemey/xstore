import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../../../../shared/widgets/skeletons/product_detail_skeleton.dart';
import '../providers/product_detail_notifier.dart';
import '../widgets/product_description.dart';
import '../widgets/product_header.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_specifications.dart';
import '../widgets/product_sticky_bar.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/reviews_summary.dart';
import '../widgets/seller_card.dart';
import '../widgets/similar_products_section.dart';
import '../../../../core/network/dio_error_mapper.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  /// Rounded top of the Orbit content panel; the gallery's dots sit above it.
  static const double _panelRadius = 30;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewsKey = GlobalKey();
  late final ValueNotifier<double> _appBarFill = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = AppSpacing.x4l * 2 + AppSpacing.x3l + AppSpacing.md;
    final next = (_scrollController.offset / threshold)
        .clamp(0.0, 1.0)
        .toDouble();
    if ((next - _appBarFill.value).abs() > 0.02) {
      _appBarFill.value = next;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _appBarFill.dispose();
    super.dispose();
  }

  Future<void> _shareListing(String title, String id) async {
    await Share.share(
      '$title — ${context.l10n.appName} · ${AppRoutes.product}/$id',
    );
  }

  Future<void> _buyNow(String productId) async {
    if (!requireLogin(context, ref)) return;
    final notifier = ref.read(productDetailProvider(productId).notifier);
    await notifier.addToCart();
    if (!mounted) return;
    final cartError = ref.read(cartProvider).error;
    if (cartError != null) {
      AppSnackbar.error(context, resolveAppError(context, cartError));
      ref.read(cartProvider.notifier).clearError();
      return;
    }
    context.push(AppRoutes.checkout);
  }

  void _scrollToReviews() {
    final ctx = _reviewsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    }
  }

  void _openSimilar(DealEntity deal) {
    context.pushReplacement('${AppRoutes.product}/${deal.id}');
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(productDetailProvider(widget.productId));

    return asyncState.when(
      loading: () =>
          const Scaffold(body: OrbitBackground(child: ProductDetailSkeleton())),
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      error: (e, _) => _StatusScaffold(
        child: ErrorStateWidget(
          message: userErrorMessage(e),
          retryLabel: context.l10n.retry,
          onRetry: () => ref
              .read(productDetailProvider(widget.productId).notifier)
              .fetchProduct(widget.productId),
        ),
      ),
      data: (data) {
        final listing = data.listing;
        if (listing == null) {
          return _StatusScaffold(
            child: Center(
              child: Text(
                context.l10n.productNotFound,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
          );
        }
        final notifier = ref.read(
          productDetailProvider(widget.productId).notifier,
        );
        final sessionUser = ref.watch(
          authProvider.select((a) => a.valueOrNull),
        );
        final isVendor = sessionUser?.isVendor == true;
        final ownerId = listing.vendorId.isNotEmpty
            ? listing.vendorId
            : (data.seller?.id ?? '');
        final isOwnListing =
            sessionUser != null &&
            sessionUser.id.isNotEmpty &&
            ownerId.isNotEmpty &&
            sessionUser.id == ownerId;
        final reviewSummary = data.reviewSummary;
        final panelColor = context.surfaceColor.withValues(alpha: 0.92);

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          body: OrbitBackground(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                AnimatedBuilder(
                  animation: _appBarFill,
                  builder: (context, _) {
                    final fill = _appBarFill.value;
                    return SliverAppBar(
                      pinned: true,
                      stretch: true,
                      expandedHeight: AppSpacing.x4l * 8 - AppSpacing.x3l,
                      elevation: 0,
                      backgroundColor: panelColor.withValues(
                        alpha: panelColor.a * fill,
                      ),
                      surfaceTintColor: AppColors.transparent,
                      systemOverlayStyle: context.isDark
                          ? SystemUiOverlayStyle.light
                          : SystemUiOverlayStyle.dark,
                      leadingWidth: AppSpacing.lg + 44,
                      leading: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: AppSpacing.lg,
                        ),
                        child: Center(
                          child: AuthBackButton(onPressed: () => context.pop()),
                        ),
                      ),
                      actions: [
                        Material(
                          color: context.glassColor,
                          shape: CircleBorder(
                            side: BorderSide(color: context.borderColor),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            tooltip: context.l10n.share,
                            constraints: const BoxConstraints.tightFor(
                              width: 44,
                              height: 44,
                            ),
                            icon: Icon(
                              LucideIcons.share2,
                              size: 20,
                              color: context.textPrimary,
                            ),
                            onPressed: () =>
                                _shareListing(listing.title, listing.id),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        WishHeartButton(
                          listingId: listing.id,
                          size: 32,
                          glass: true,
                        ),
                        const Gap(AppSpacing.lg),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        stretchModes: const [
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                        ],
                        background: ProductImageGallery(
                          titleForSemantics: listing.title,
                          imageUrls: listing.imageUrls,
                          selectedIndex: data.selectedImageIndex,
                          onPageChanged: notifier.selectImage,
                        ).animate().fadeIn(duration: AppAnimations.medium),
                      ),
                    );
                  },
                ),
                // Orbit content panel: one rounded sheet under the gallery
                // holding every section.
                DecoratedSliver(
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(_panelRadius),
                    ),
                    border: Border(top: BorderSide(color: context.borderColor)),
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProductHeader(
                          listing: listing,
                          compareAtPrice: data.compareAtPrice,
                          locationLine: data.locationLine,
                          onTapReviews: _scrollToReviews,
                          ratingLabel:
                              reviewSummary != null &&
                                  reviewSummary.totalCount > 0
                              ? reviewSummary.average.toStringAsFixed(1)
                              : null,
                          reviewCountLabel:
                              reviewSummary != null &&
                                  reviewSummary.totalCount > 0
                              ? _formatCount(reviewSummary.totalCount)
                              : null,
                        ).fadeSlideIn(delay: const Duration(milliseconds: 150)),
                      ),
                      if (data.seller != null)
                        SliverToBoxAdapter(
                          child: SellerCard(
                            seller: data.seller!,
                            onVisitStore: () => context.push(
                              '${AppRoutes.sellerProfile}/${data.seller!.id}',
                            ),
                            onCardTap: () => context.push(
                              '${AppRoutes.sellerProfile}/${data.seller!.id}',
                            ),
                          ).fadeSlideIn(delay: const Duration(milliseconds: 200)),
                        ),
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      SliverToBoxAdapter(
                        child: ProductDescription(
                          text: listing.description,
                          expanded: data.isDescriptionExpanded,
                          onToggle: notifier.toggleDescription,
                        ).fadeSlideIn(delay: const Duration(milliseconds: 250)),
                      ),
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      if (data.specifications.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: ProductSpecifications(
                            specifications: data.specifications,
                          ),
                        ),
                        const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      ],
                      if (!isOwnListing) ...[
                        SliverToBoxAdapter(
                          child:
                              QuantitySelector(
                                quantity: data.quantity,
                                maxQuantity: data.stockQuantity,
                                onDecrement: notifier.decrementQuantity,
                                onIncrement: notifier.incrementQuantity,
                              ).fadeSlideIn(
                                delay: const Duration(milliseconds: 280),
                              ),
                        ),
                        const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      ],
                      SliverToBoxAdapter(
                        child: SimilarProductsSection(
                          products: data.similarProducts,
                          onOpenProduct: _openSimilar,
                        ),
                      ),
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      if (reviewSummary != null &&
                          (data.reviews.isNotEmpty ||
                              reviewSummary.totalCount > 0))
                        SliverToBoxAdapter(
                          child: KeyedSubtree(
                            key: _reviewsKey,
                            child: ReviewsSummary(
                              summary: reviewSummary,
                              reviews: data.reviews,
                              onSeeAll: () => context.push(
                                '${AppRoutes.product}/${listing.id}/reviews',
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: isOwnListing
                              ? AppSpacing.x3l +
                                    MediaQuery.paddingOf(context).bottom
                              : AppSpacing.x4l * 2 +
                                    AppSpacing.x3l +
                                    MediaQuery.paddingOf(context).bottom +
                                    MediaQuery.viewInsetsOf(context).bottom,
                        ),
                      ),
                    ],
                  ),
                ),
                // Carries the panel to the bottom edge on short listings.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ColoredBox(color: panelColor),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isOwnListing
              ? null
              : AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child:
                      ProductStickyBar(
                        showAddToCart: !isVendor,
                        isSoldOut: data.stockQuantity < 1,
                        isAddingToCart: data.isAddingToCart,
                        onAddToCart: () async {
                          if (!requireLogin(context, ref)) return;
                          await notifier.addToCart();
                          if (!context.mounted) return;
                          final cartError = ref.read(cartProvider).error;
                          if (cartError != null) {
                            AppSnackbar.error(
                              context,
                              resolveAppError(context, cartError),
                            );
                            ref.read(cartProvider.notifier).clearError();
                            return;
                          }
                          AppSnackbar.success(
                            context,
                            context.l10n.addedToCart,
                          );
                        },
                        onBuyNow: () => _buyNow(widget.productId),
                      ).animate().slideY(
                        begin: 1,
                        end: 0,
                        duration: AppAnimations.medium,
                        curve: AppAnimations.enter,
                      ),
                ),
        );
      },
    );
  }

  String _formatCount(int n) {
    final s = n.toString();
    return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

/// Error / not-found state: Orbit sky with the frosted back button.
class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (Navigator.of(context).canPop())
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: AuthBackButton(),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
