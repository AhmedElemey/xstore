import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/cart_line_entity.dart';

part 'cart_notifier.g.dart';

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartLineEntity> build() => [];

  void addItem(ListingEntity listing, int quantity) {
    if (quantity <= 0) return;
    final imageUrl =
        listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null;
    final idx = state.indexWhere((e) => e.listingId == listing.id);
    if (idx >= 0) {
      final line = state[idx];
      final next = line.copyWith(quantity: line.quantity + quantity);
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx) next else state[i],
      ];
      return;
    }
    state = [
      ...state,
      CartLineEntity(
        listingId: listing.id,
        title: listing.title,
        unitPrice: listing.price,
        imageUrl: imageUrl,
        quantity: quantity,
      ),
    ];
  }
}
