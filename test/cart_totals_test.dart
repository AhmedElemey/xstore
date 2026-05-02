import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';

CouponEntity pctCoupon(double pct, {double min = 0, double? maxD}) =>
    CouponEntity(
      code: 'PCT',
      discountType: DiscountType.percentage,
      discountValue: pct,
      minOrderAmount: min,
      maxDiscount: maxD,
    );

CartItemEntity _item({
  required String id,
  required double price,
  required int qty,
  double ship = 0,
}) =>
    CartItemEntity(
      id: id,
      listingId: 'l$id',
      listingName: id,
      listingImage: '',
      price: price,
      quantity: qty,
      maxQuantity: 99,
      category: 'c',
      condition: 'new',
      shippingCost: ship,
      isAvailable: true,
      vendorId: 'v1',
      vendorName: 'Vendor',
      vendorStoreName: 'Shop',
      addedAt: DateTime(2026, 1, 1),
    );

CartState cartWithSelection(CartState base, CouponEntity? coupon) {
  var sub = 0.0;
  var ship = 0.0;
  for (final it in base.selectedAvailableItems) {
    sub += it.price * it.quantity;
    ship += it.shippingCost;
  }
  final disc = coupon != null ? cartDiscountOnSubtotal(sub, coupon) : 0.0;
  return base.copyWith(
    coupon: coupon,
    discount: disc,
    subtotal: sub,
    shippingTotal: ship,
    total: sub + ship - disc,
  );
}

void main() {
  test('percentage discount respects cap', () {
    const sub = 200.0;
    final coupon = pctCoupon(10, maxD: 15);
    expect(cartDiscountOnSubtotal(sub, coupon), 15);
    expect(sub - cartDiscountOnSubtotal(sub, coupon), 185);
  });

  test('coupon below minimum order contributes zero discount', () {
    final coupon =
        pctCoupon(20, min: 1000);
    expect(cartDiscountOnSubtotal(50, coupon), 0);
  });

  test('shipping included in totals with discount', () {
    final items = [
      _item(id: 'a', price: 100, qty: 2, ship: 5),
      _item(id: 'b', price: 50, qty: 1, ship: 3),
    ];
    final base = CartState(
      items: items,
      selectedItemIds: {'a', 'b'},
    );
    final withCoupon = cartWithSelection(base, pctCoupon(10));
    expect(withCoupon.subtotal, 250);
    expect(withCoupon.shippingTotal, 8);
    expect(withCoupon.discount, 25);
    expect(withCoupon.total, 233);
  });

  test('fixed discount cannot exceed subtotal', () {
    final coupon = const CouponEntity(
      code: 'FIX',
      discountType: DiscountType.fixed,
      discountValue: 999,
    );
    expect(cartDiscountOnSubtotal(10, coupon), 10);
  });
}
