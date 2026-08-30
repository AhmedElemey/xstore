import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/deeplink/deep_link_route.dart';
import 'package:xstore/core/router/app_routes.dart';

void main() {
  group('routeFromDeepLinkUri', () {
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
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/category/shoes')),
        isNull,
      );
    });

    test('rejects a product link with no id', () {
      expect(
        routeFromDeepLinkUri(Uri.parse('https://xstore.com/product/')),
        isNull,
      );
    });
  });
}
