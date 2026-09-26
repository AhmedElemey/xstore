import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/deeplink/deep_link_route.dart';
import 'package:xstore/core/router/app_routes.dart';

void main() {
  group('routeFromDeepLinkUri', () {
    test('productDeepLink is a product link the app opens', () {
      final link = productDeepLink('abc-123');
      expect(link, 'https://xstore.com/product/abc-123');
      expect(
        routeFromDeepLinkUri(Uri.parse(link)),
        '${AppRoutes.product}/abc-123',
      );
    });

    test('resolves a product link on the primary host', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/product/abc-123')),
        '${AppRoutes.product}/abc-123',
      );
    });

    test('resolves a product link on the www host', () {
      expect(
        routeFromDeepLinkUri(
          Uri.parse('https://www.xstore.com/product/abc-123'),
        ),
        '${AppRoutes.product}/abc-123',
      );
    });

    test('rejects an unrecognized host', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://evil.test/product/abc-123')),
        isNull,
      );
    });

    test('rejects an unrecognized path', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/coupon/shoes')),
        isNull,
      );
    });

    test('rejects a product link with no id', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/product/')),
        isNull,
      );
    });

    test('resolves a seller link', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/seller/vendor-9')),
        AppRoutes.sellerPath('vendor-9'),
      );
    });

    test('resolves an order link', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/order/ord-42')),
        AppRoutes.orderPath('ord-42'),
      );
    });

    test('resolves a category link', () {
      expect(
        routeFromDeepLinkUri(
          Uri.parse('https://xstore.com/category/Home%20%26%20Kitchen'),
        ),
        '${AppRoutes.explore}?category=Home%20%26%20Kitchen',
      );
    });

    test('rejects a link with no id segment', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/seller/')),
        isNull,
      );
    });

    test('rejects a link with extra path segments', () {
      expect(
        routeFromDeepLinkUri(
          Uri.parse('https://xstore.com/product/abc-123/reviews'),
        ),
        isNull,
      );
    });
  });
}
