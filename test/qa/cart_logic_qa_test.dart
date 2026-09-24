// QA suite (2026-09-24): cart pure logic — discount, shipping, grouping,
// selection totals. No network; exercises the notifier's own math via
// CartStateX + the free functions the provider uses.
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_shipping_rules.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';

CartItemEntity item(
  String id, {
  double price = 100,
  int qty = 1,
  double shipping = 0,
  bool shippingAvailable = false,
  bool available = true,
  String vendor = 'v1',
  int maxQty = 10,
}) =>
    CartItemEntity(
      id: id,
      listingId: 'l_$id',
      listingName: id,
      listingImage: '',
      vendorId: vendor,
      vendorName: vendor,
      vendorStoreName: vendor,
      price: price,
      quantity: qty,
      maxQuantity: maxQty,
      category: 'c',
      condition: 'new',
      shippingAvailable: shippingAvailable,
      shippingCost: shipping,
      isAvailable: available,
      addedAt: DateTime(2026),
    );

void main() {
  group('cartDiscountOnSubtotal', () {
    CouponEntity pct(double v, {double? max, double? min}) => CouponEntity(
          code: 'C',
          discountType: DiscountType.percentage,
          discountValue: v,
          maxDiscount: max,
          minOrderAmount: min,
        );
    CouponEntity fixed(double v, {double? min}) => CouponEntity(
          code: 'C',
          discountType: DiscountType.fixed,
          discountValue: v,
          minOrderAmount: min,
        );

    test('percentage, capped by maxDiscount', () {
      expect(cartDiscountOnSubtotal(1000, pct(10)), 100);
      expect(cartDiscountOnSubtotal(1000, pct(10, max: 50)), 50);
    });

    test('fixed discount never exceeds subtotal', () {
      expect(cartDiscountOnSubtotal(100, fixed(500)), 100);
      expect(cartDiscountOnSubtotal(600, fixed(500)), 500);
    });

    test('minOrderAmount gate', () {
      expect(cartDiscountOnSubtotal(400, fixed(50, min: 500)), 0);
      expect(cartDiscountOnSubtotal(500, fixed(50, min: 500)), 50);
    });

    test('invalid coupon contributes nothing', () {
      final invalid = CouponEntity(
        code: 'X',
        discountType: DiscountType.fixed,
        discountValue: 100,
        isValid: false,
      );
      expect(cartDiscountOnSubtotal(1000, invalid), 0);
    });

    test('zero subtotal never yields a negative or nonzero discount', () {
      expect(cartDiscountOnSubtotal(0, pct(10)), 0);
      expect(cartDiscountOnSubtotal(0, fixed(100)), 0);
    });

    test('a 100% coupon cannot make the order cost more than free', () {
      expect(cartDiscountOnSubtotal(250, pct(100)), 250);
      expect(cartDiscountOnSubtotal(250, pct(150)), lessThanOrEqualTo(250));
    });
  });

  group('cartLineShippingCost', () {
    test('no shipping when unavailable or non-positive', () {
      expect(
        cartLineShippingCost(shippingAvailable: false, listingShippingCost: 50),
        0,
      );
      expect(
        cartLineShippingCost(shippingAvailable: true, listingShippingCost: 0),
        0,
      );
      expect(
        cartLineShippingCost(shippingAvailable: true, listingShippingCost: -5),
        0,
      );
    });

    test('charges the listed cost when available and positive', () {
      expect(
        cartLineShippingCost(shippingAvailable: true, listingShippingCost: 40),
        40,
      );
    });
  });

  group('CartStateX derived views', () {
    test('vendorGroups preserve first-seen order and per-group subtotal', () {
      final st = CartState(items: [
        item('a', vendor: 'v1', price: 100, qty: 2),
        item('b', vendor: 'v2', price: 50),
        item('c', vendor: 'v1', price: 10),
      ]);
      final groups = st.vendorGroups;
      expect(groups.map((g) => g.vendorId), ['v1', 'v2']);
      expect(groups.first.groupSubtotal, 210); // 100*2 + 10
      expect(groups.first.items.length, 2);
    });

    test('selectedAvailableItems ignores unselected and unavailable', () {
      final st = CartState(
        items: [
          item('a'),
          item('b', available: false),
          item('c'),
        ],
        selectedItemIds: {'a', 'b'},
      );
      expect(st.selectedAvailableItems.map((e) => e.id), ['a']);
    });

    test('hasUnavailable / itemCount / selectedCount', () {
      final st = CartState(
        items: [item('a'), item('b', available: false)],
        selectedItemIds: {'a'},
      );
      expect(st.hasUnavailable, isTrue);
      expect(st.itemCount, 2);
      expect(st.selectedCount, 1);
    });
  });
}
