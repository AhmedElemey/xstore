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
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
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
  late final ValueNotifier<double> _appBarFill = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = AppSpacing.x4l * 2 + AppSpacing.x3l + AppSpacing.md;
    final next =
        (_scrollController.offset / threshold).clamp(0.0, 1.0).toDouble();
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
    await Share.share('$title — ${context.l10n.appName} · ${AppRoutes.product}/$id');
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
        final notifier =
            ref.read(productDetailProvider(widget.productId).notifier);
        final isVendor = ref.watch(
          authProvider.select((a) => a.valueOrNull?.isVendor == true),
        );
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
                  AnimatedBuilder(
                    animation: _appBarFill,
                    builder: (context, _) {
                      final fill = _appBarFill.value;
                      final blended = Color.lerp(
                            context.surfaceColor,
                            context.iconPrimary,
                            fill,
                          )!;
                      return SliverAppBar(
                        pinned: true,
                        stretch: true,
                        expandedHeight:
                            AppSpacing.x4l * 8 - AppSpacing.x3l,
                        elevation: fill > 0.9 ? 2 : 0,
                        shadowColor: context.cardShadowColor,
                        backgroundColor:
                            context.surfaceColor.withValues(alpha: fill),
                        surfaceTintColor: AppColors.transparent,
                        systemOverlayStyle: fill > 0.55
                            ? SystemUiOverlayStyle.dark
                            : SystemUiOverlayStyle.light,
                        iconTheme: IconThemeData(color: blended),
                        actionsIconTheme: IconThemeData(color: blended),
                        leading: IconButton(
                          tooltip:
                              MaterialLocalizations.of(context).backButtonTooltip,
                          icon: Icon(LucideIcons.chevronLeft, color: blended),
                          onPressed: () => context.pop(),
                        ),
                        actions: [
                          IconButton(
                            tooltip: context.l10n.share,
                            icon:
                                Icon(LucideIcons.share2, color: blended),
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
                            titleForSemantics: listing.title,
                            imageUrls: listing.imageUrls,
                            selectedIndex: data.selectedImageIndex,
                            onPageChanged: notifier.selectImage,
                            listingId: listing.id,
                          )
                              .animate()
                              .fadeIn(duration: AppAnimations.medium),
                        ),
                      );
                    },
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
                    ).fadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: const QuickActionsRow().fadeSlideIn(
                      delay: const Duration(milliseconds: 180),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
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
                      ).fadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                      ),
                    ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                  SliverToBoxAdapter(
                    child: ProductDescription(
                      text: listing.description,
                      expanded: data.isDescriptionExpanded,
                      onToggle: notifier.toggleDescription,
                    ).fadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                  SliverToBoxAdapter(
                    child: ProductSpecifications(
                      specifications: data.specifications,
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(AppSpacing.x2l)),
                  SliverToBoxAdapter(
                    child: QuantitySelector(
                      quantity: data.quantity,
                      maxQuantity: data.stockQuantity,
                      onDecrement: notifier.decrementQuantity,
                      onIncrement: notifier.incrementQuantity,
                    ).fadeSlideIn(
                      delay: const Duration(milliseconds: 280),
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
                      height: AppSpacing.x4l * 2 +
                          AppSpacing.x3l +
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
              showAddToCart: !isVendor,
              isAddingToCart: data.isAddingToCart,
              onChat: () {
                AppSnackbar.info(context, context.l10n.chatSellerSoon);
              },
              onAddToCart: () async {
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
              onBuyNow: () {
                AppSnackbar.info(context, context.l10n.expressCheckoutSoon);
              },
            )
                .animate()
                .slideY(
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
    return s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
