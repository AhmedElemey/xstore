import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../core/deeplink/deep_link_route.dart';
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
import '../widgets/reviews_summary.dart';
import '../widgets/seller_card.dart';
import '../widgets/similar_products_section.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../../../shared/widgets/wish_heart_button.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
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
      '$title — ${context.l10n.appName}\n${productDeepLink(id)}',
    );
  }

  // TODO(phase-2): Seller chat is deferred to the next phase. Restore this
  // with the product chat button, and re-add the whatsapp + analytics imports:
  //   import '../../../../core/analytics/analytics_service.dart';
  //   import '../../../../core/analytics/event_names.dart';
  //   import '../../../../shared/utils/whatsapp.dart';
  // Future<void> _messageSeller({
  //   required String listingId,
  //   required String listingTitle,
  //   String? sellerId,
  //   String? whatsapp,
  // }) async {
  //   final text = context.l10n.whatsappProductPrefill(listingTitle);
  //   final opened = await launchWhatsApp(phone: whatsapp ?? '', prefilledText: text);
  //   if (!mounted) return;
  //   if (!opened) {
  //     AppSnackbar.info(context, context.l10n.whatsappSellerUnavailable);
  //     return;
  //   }
  //   ref.read(analyticsServiceProvider).track(
  //     AnalyticsEvents.whatsappSellerTap,
  //     properties: {
  //       AnalyticsProps.source: 'product',
  //       AnalyticsProps.itemId: listingId,
  //       if (sellerId != null) AnalyticsProps.sellerId: sellerId,
  //     },
  //   );
  // }

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
      loading: () => const Scaffold(body: ProductDetailSkeleton()),
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.productScreenTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.toString(), textAlign: TextAlign.center),
                const Gap(AppSpacing.lg),
                XstoreButton(
                  label: context.l10n.retry,
                  onPressed: () => ref
                      .read(productDetailProvider(widget.productId).notifier)
                      .fetchProduct(widget.productId),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) {
        final listing = data.listing;
        if (listing == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.productNotFound)),
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

        final showCartBar = !isOwnListing && !isVendor;
        final sheetColor = context.isDark
            ? const Color(0xEB0C1030)
            : AppColors.white.withValues(alpha: 0.92);
        const side = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          body: SpaceBackground(
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
                      expandedHeight: 360,
                      elevation: 0,
                      backgroundColor: context.backgroundColor.withValues(
                        alpha: fill * 0.92,
                      ),
                      surfaceTintColor: AppColors.transparent,
                      systemOverlayStyle: context.isDark
                          ? SystemUiOverlayStyle.light
                          : SystemUiOverlayStyle.dark,
                      leadingWidth: 64,
                      leading: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: AppSpacing.lg,
                        ),
                        child: Center(
                          child: OrbitCircleButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).backButtonTooltip,
                            onPressed: () => context.pop(),
                            child: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? LucideIcons.chevronRight
                                  : LucideIcons.chevronLeft,
                              size: 22,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        OrbitCircleButton(
                          tooltip: context.l10n.share,
                          onPressed: () =>
                              _shareListing(listing.title, listing.id),
                          child: Icon(
                            LucideIcons.share,
                            size: 20,
                            color: context.textPrimary,
                          ),
                        ),
                        if (!isVendor) ...[
                          const Gap(AppSpacing.sm + 2),
                          WishHeartButton(listingId: listing.id, size: 22),
                        ],
                        const Gap(AppSpacing.lg),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        stretchModes: const [StretchMode.zoomBackground],
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
                DecoratedSliver(
                  decoration: BoxDecoration(
                    color: sheetColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border(top: BorderSide(color: context.borderColor)),
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          22,
                          AppSpacing.lg,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child:
                              ProductHeader(
                                listing: listing,
                                compareAtPrice: data.compareAtPrice,
                                locationLine: data.locationLine,
                              ).fadeSlideIn(
                                delay: const Duration(milliseconds: 150),
                              ),
                        ),
                      ),
                      if (data.seller != null) ...[
                        const SliverToBoxAdapter(child: Gap(AppSpacing.md)),
                        SliverPadding(
                          padding: side,
                          sliver: SliverToBoxAdapter(
                            child: SellerCard(
                              seller: data.seller!,
                              onTap: () => context.push(
                                '${AppRoutes.sellerProfile}/${data.seller!.id}',
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!isOwnListing) ...[
                        const SliverToBoxAdapter(child: Gap(AppSpacing.md)),
                        SliverToBoxAdapter(
                          child: ProductActionsRow(
                            stockLeft: data.stockQuantity,
                            onBuyNow: () => _buyNow(widget.productId),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: Gap(AppSpacing.md)),
                      SliverToBoxAdapter(
                        child: ProductDescription(
                          text: listing.description,
                          expanded: data.isDescriptionExpanded,
                          onToggle: notifier.toggleDescription,
                        ),
                      ),
                      SliverPadding(
                        padding: side,
                        sliver: SliverToBoxAdapter(
                          child: ProductRatingLink(
                            onTap: _scrollToReviews,
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
                          ),
                        ),
                      ),
                      // App-only sections the design has no slot for.
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      // const SliverToBoxAdapter(child: QuickActionsRow()),
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                      SliverToBoxAdapter(
                        child: ProductSpecifications(
                          specifications: data.specifications,
                        ),
                      ),
                      const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
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
                          height:
                              (showCartBar
                                  ? AppSpacing.x4l * 2 + AppSpacing.x3l
                                  : AppSpacing.x3l) +
                              MediaQuery.paddingOf(context).bottom,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: !showCartBar
              ? null
              : AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child:
                      ProductStickyBar(
                        isAddingToCart: data.isAddingToCart,
                        quantity: data.quantity,
                        maxQuantity: data.stockQuantity,
                        onDecrement: notifier.decrementQuantity,
                        onIncrement: notifier.incrementQuantity,
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
