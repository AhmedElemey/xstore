import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/review_entity.dart';
import 'product_dependencies.dart';
import 'product_detail_state.dart';

part 'product_detail_notifier.g.dart';

@riverpod
class ProductDetail extends _$ProductDetail {
  ProductDetailState _fromEntity(ProductDetailEntity e) {
    return ProductDetailState(
      listing: e.listing,
      compareAtPrice: e.compareAtPrice,
      stockQuantity: e.stockQuantity,
      locationLine: e.locationLine,
      seller: e.seller,
      specifications: e.specifications,
      reviewSummary: e.reviewSummary,
      reviews: e.reviews,
      similarProducts: e.similarProducts,
    );
  }

  ProductDetailState _mergeWithPrevious(
    ProductDetailEntity e,
    ProductDetailState? previous,
  ) {
    final base = _fromEntity(e);
    if (previous == null) return base;
    final len = base.listing?.imageUrls.length ?? 0;
    final maxIdx = len > 0 ? len - 1 : 0;
    return base.copyWith(
      quantity: previous.quantity.clamp(1, base.stockQuantity),
      selectedImageIndex: previous.selectedImageIndex.clamp(0, maxIdx),
      isDescriptionExpanded: previous.isDescriptionExpanded,
      isAddingToCart: false,
    );
  }

  Future<ProductDetailEntity> _fetchEntity(String id) async {
    final r = await ref.read(getProductDetailUseCaseProvider).call(id);
    return r.fold((f) => throw f, (e) => e);
  }

  Future<ProductDetailEntity> _enriched(String listingId, ProductDetailEntity entity) async {
    final similarResult = await ref.read(getSimilarProductsUseCaseProvider).call(
          productId: listingId,
          category: entity.listing.categoryLabel,
        );
    final reviewsResult = await ref.read(getProductReviewsUseCaseProvider).call(listingId);

    final simList = similarResult.fold((_) => <ProductDetailEntity>[], (l) => l);
    final deals = simList.map((p) {
      final discount = p.compareAtPrice != null && p.compareAtPrice! > p.listing.price
          ? (((p.compareAtPrice! - p.listing.price) / p.compareAtPrice!) * 100).round()
          : 0;
      return DealEntity(
        id: p.listing.id,
        title: p.listing.title,
        price: p.listing.price,
        imageUrl: p.listing.imageUrls.isNotEmpty ? p.listing.imageUrls.first : null,
        discountPercent: discount.toDouble(),
      );
    }).toList();

    final revList = reviewsResult.fold((_) => <ReviewEntity>[], (l) => l);
    final uiReviews = revList
        .map(
          (r) => ProductReviewEntity(
            id: r.id,
            userName: r.userName,
            userAvatarUrl: r.userAvatar,
            date: r.createdAt,
            stars: r.rating,
            text: r.comment,
            helpfulCount: r.helpfulCount,
          ),
        )
        .toList();

    return entity.copyWith(
      similarProducts: deals,
      reviews: uiReviews,
    );
  }

  @override
  Future<ProductDetailState> build(String listingId) async {
    final entity = await _fetchEntity(listingId);
    final merged = await _enriched(listingId, entity);
    return _fromEntity(merged);
  }

  Future<void> fetchProduct(String id) async {
    if (id != listingId) return;
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final entity = await _fetchEntity(id);
      final merged = await _enriched(id, entity);
      return _mergeWithPrevious(merged, previous);
    });
  }

  void incrementQuantity() {
    final v = state.valueOrNull;
    if (v?.listing == null) return;
    final maxQ = v!.stockQuantity;
    if (v.quantity >= maxQ) return;
    state = AsyncData(v.copyWith(quantity: v.quantity + 1));
  }

  void decrementQuantity() {
    final v = state.valueOrNull;
    if (v == null || v.quantity <= 1) return;
    state = AsyncData(v.copyWith(quantity: v.quantity - 1));
  }

  Future<void> addToCart() async {
    final v = state.valueOrNull;
    final listing = v?.listing;
    if (listing == null) return;
    state = AsyncData(v!.copyWith(isAddingToCart: true));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await ref.read(cartProvider.notifier).addListingEntity(listing, v.quantity);
    state = AsyncData(v.copyWith(isAddingToCart: false));
  }

  void selectImage(int index) {
    final v = state.valueOrNull;
    if (v?.listing == null) return;
    final n = v!.listing!.imageUrls.length;
    if (n == 0 || index < 0 || index >= n) return;
    state = AsyncData(v.copyWith(selectedImageIndex: index));
  }

  void toggleDescription() {
    final v = state.valueOrNull;
    if (v == null) return;
    state = AsyncData(v.copyWith(isDescriptionExpanded: !v.isDescriptionExpanded));
  }
}
