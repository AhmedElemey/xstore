import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/cart/domain/entities/cart_shipping_rules.dart';

// The cart total itself (subtotal + shipping) is checked against the real
// notifier in test/qa/regression_gaps_qa_test.dart (M02).
void main() {
  test('cartLineShippingCost uses the listing fee, not a platform flat fee', () {
    expect(
      cartLineShippingCost(shippingAvailable: true, listingShippingCost: 35),
      35,
    );
    expect(
      cartLineShippingCost(shippingAvailable: true, listingShippingCost: 0),
      0,
    );
    expect(
      cartLineShippingCost(shippingAvailable: false, listingShippingCost: 500),
      0,
    );
  });
}
