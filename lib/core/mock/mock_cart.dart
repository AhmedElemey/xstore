import '../../features/cart/domain/entities/cart_line_entity.dart';
import 'mock_listings.dart';

/// Pre-built cart lines for UI/tests (cart [Notifier] still starts empty unless seeded).
List<CartLineEntity> get mockCartLines => [
      CartLineEntity(
        listingId: 'listing_009',
        title: mockListingModels[8].title,
        unitPrice: mockListingModels[8].price,
        imageUrl: mockListingModels[8].imageUrls.isNotEmpty
            ? mockListingModels[8].imageUrls.first
            : null,
        quantity: 1,
      ),
      CartLineEntity(
        listingId: 'listing_003',
        title: mockListingModels[2].title,
        unitPrice: mockListingModels[2].price,
        imageUrl: mockListingModels[2].imageUrls.isNotEmpty
            ? mockListingModels[2].imageUrls.first
            : null,
        quantity: 2,
      ),
      CartLineEntity(
        listingId: 'listing_016',
        title: mockListingModels[15].title,
        unitPrice: mockListingModels[15].price,
        imageUrl: mockListingModels[15].imageUrls.isNotEmpty
            ? mockListingModels[15].imageUrls.first
            : null,
        quantity: 1,
      ),
    ];

/// Aggregates for cart summary widgets / checkout mocks.
class MockCartSummary {
  const MockCartSummary({
    required this.subtotal,
    required this.shippingTotal,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double shippingTotal;
  final double discount;
  final double total;
}

const mockCartSummary = MockCartSummary(
  subtotal: 148000,
  shippingTotal: 500,
  discount: 0,
  total: 148500,
);
