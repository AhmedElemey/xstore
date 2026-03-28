import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/product_detail_entity.dart';
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
      isFavorite: previous.isFavorite,
      selectedImageIndex: previous.selectedImageIndex.clamp(0, maxIdx),
      isDescriptionExpanded: previous.isDescriptionExpanded,
      isAddingToCart: false,
    );
  }

  @override
  Future<ProductDetailState> build(String listingId) async {
    final useCase = ref.read(getProductDetailUseCaseProvider);
    final result = await useCase(listingId);
    return result.fold(
      (f) => throw f,
      _fromEntity,
    );
  }

  Future<void> fetchProduct(String id) async {
    if (id != listingId) return;
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getProductDetailUseCaseProvider);
      final result = await useCase(id);
      return result.fold(
        (f) => throw f,
        (e) => _mergeWithPrevious(e, previous),
      );
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

  void toggleFavorite() {
    final v = state.valueOrNull;
    if (v == null) return;
    state = AsyncData(v.copyWith(isFavorite: !v.isFavorite));
  }

  Future<void> addToCart() async {
    final v = state.valueOrNull;
    final listing = v?.listing;
    if (listing == null) return;
    state = AsyncData(v!.copyWith(isAddingToCart: true));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    ref.read(cartProvider.notifier).addItem(listing, v.quantity);
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
