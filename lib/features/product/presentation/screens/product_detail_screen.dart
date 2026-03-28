import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../providers/product_detail_notifier.dart';
import '../widgets/product_description.dart';
import '../widgets/product_header.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_specifications.dart';
import '../widgets/product_sticky_bar.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/reviews_summary.dart';
import '../widgets/seller_card.dart';
import '../widgets/similar_products_section.dart';

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
  double _appBarFill = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    const threshold = 110;
    final next =
        (_scrollController.offset / threshold).clamp(0.0, 1.0).toDouble();
    if ((next - _appBarFill).abs() > 0.02) {
      setState(() => _appBarFill = next);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _shareListing(String title, String id) async {
    await Share.share('$title — xStore · ${AppRoutes.product}/$id');
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.toString(), textAlign: TextAlign.center),
                const Gap(AppSpacing.md),
                FilledButton(
                  onPressed: () => ref
                      .read(productDetailProvider(widget.productId).notifier)
                      .fetchProduct(widget.productId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) {
        final listing = data.listing;
        if (listing == null) {
          return const Scaffold(
            body: Center(child: Text('Product not found')),
          );
        }
        final notifier =
            ref.read(productDetailProvider(widget.productId).notifier);
        final iconColor =
            Color.lerp(Colors.white, Colors.black87, _appBarFill)!;
        final reviewSummary = data.reviewSummary;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    expandedHeight: 380,
                    elevation: _appBarFill > 0.9 ? 2 : 0,
                    shadowColor: Colors.black26,
                    backgroundColor:
                        Colors.white.withValues(alpha: _appBarFill),
                    surfaceTintColor: Colors.transparent,
                    systemOverlayStyle: _appBarFill > 0.55
                        ? SystemUiOverlayStyle.dark
                        : SystemUiOverlayStyle.light,
                    iconTheme: IconThemeData(color: iconColor),
                    actionsIconTheme: IconThemeData(color: iconColor),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: iconColor),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      IconButton(
                        icon:
                            Icon(Icons.share_outlined, color: iconColor),
                        onPressed: () =>
                            _shareListing(listing.title, listing.id),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: ProductImageGallery(
                        imageUrls: listing.imageUrls,
                        selectedIndex: data.selectedImageIndex,
                        onPageChanged: notifier.selectImage,
                        isFavorite: data.isFavorite,
                        onToggleFavorite: notifier.toggleFavorite,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ProductHeader(
                      listing: listing,
                      compareAtPrice: data.compareAtPrice,
                      locationLine: data.locationLine,
                      onTapReviews: _scrollToReviews,
                      ratingLabel: reviewSummary != null
                          ? reviewSummary.average.toStringAsFixed(1)
                          : '4.7',
                      reviewCountLabel: reviewSummary != null
                          ? _formatCount(reviewSummary.totalCount)
                          : '1,230',
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.md)),
                  const SliverToBoxAdapter(child: QuickActionsRow()),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
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
                      ),
                    ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: ProductDescription(
                      text: listing.description,
                      expanded: data.isDescriptionExpanded,
                      onToggle: notifier.toggleDescription,
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: ProductSpecifications(
                      specifications: data.specifications,
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: QuantitySelector(
                      quantity: data.quantity,
                      maxQuantity: data.stockQuantity,
                      onDecrement: notifier.decrementQuantity,
                      onIncrement: notifier.incrementQuantity,
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: SimilarProductsSection(
                      products: data.similarProducts,
                      onOpenProduct: _openSimilar,
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  if (reviewSummary != null && data.reviews.isNotEmpty)
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
                      height: 120 +
                          MediaQuery.paddingOf(context).bottom +
                          MediaQuery.viewInsetsOf(context).bottom,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ProductStickyBar(
              isAddingToCart: data.isAddingToCart,
              onChat: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat with seller — coming soon')),
                );
              },
              onAddToCart: () async {
                await notifier.addToCart();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                }
              },
              onBuyNow: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Express checkout — coming soon'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int n) {
    final s = n.toString();
    return s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
