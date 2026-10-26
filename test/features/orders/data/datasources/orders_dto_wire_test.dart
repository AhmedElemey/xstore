import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

/// Backend contract: `VendorOrdersResponseDto` / `OrderDto` / `OrderItemDto`
/// (camelCase JSON, enums as ints, decimals as numbers).
class _Scripted extends Interceptor {
  _Scripted(this._body);

  final Object? _body;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: _body),
    );
  }
}

OrdersRemoteDataSourceImpl _ds(Object? body) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(_Scripted(body));
  return OrdersRemoteDataSourceImpl(dio);
}

Map<String, dynamic> _fullItem() => {
      'id': 11,
      'orderId': 7,
      'listingId': 42,
      'titleSnapshot': 'Used iPhone 12',
      'priceSnapshot': 9000.0,
      'compareAtPriceSnapshot': 10000.0,
      'imageUrls': ['https://cdn.test/a.jpg', 'https://cdn.test/b.jpg'],
      'attributes': [
        {'key': 'Color', 'value': 'Blue'},
        {'key': 'Storage', 'value': '128GB'},
        {'key': 'broken'}, // malformed row is skipped individually
        'not a map',
      ],
      'qty': 2,
      'unitPrice': 8500.5,
    };

Map<String, dynamic> _fullOrder() => {
      'id': 7,
      'buyerUserId': 5,
      'buyerName': 'Mona Ali',
      'vendorName': 'Tech Store',
      'vendorId': 3,
      'status': 6,
      'payment': 'cod',
      'phone': '01012345678',
      'latitude': 30.0444,
      'longitude': 31.2357,
      'subtotal': 17001.0,
      'shipping': 60.0,
      'total': 17061.0,
      'courierId': 9,
      'cancellationReason': 'Buyer unreachable',
      'cancelledBy': 2,
      'isReviewed': true,
      'createdAt': '2026-10-20T10:30:00Z',
      'items': [_fullItem()],
    };

Map<String, dynamic> _envelope(List<Map<String, dynamic>> orders) => {
      'orders': orders,
      'totalCount': 12,
      'pendingCount': 3,
      'confirmedCount': 4,
      'totalRevenue': 25000.75,
      'outstandingBalance': 120.5,
      'warnThresholdEgp': 100.0,
      'pauseThresholdEgp': 500.0,
      'exceedsWarnThreshold': true,
      'exceedsPauseThreshold': false,
      'commissionValueOnOrder': 15.0,
    };

void main() {
  final skipMock =
      MockConfig.useMock ? 'MockConfig.useMock short-circuits Dio' : false;

  group('VendorOrdersResponseDto / OrderDto / OrderItemDto wire parsing', () {
    test('every OrderDto and OrderItemDto field is read from the DTO keys',
        () async {
      final ds = _ds(_envelope([_fullOrder()]));
      final orders =
          await ds.getVendorOrders(vendorId: '3', page: 1, pageSize: 20);
      expect(orders, hasLength(1));
      final o = orders.single;

      expect(o.id, '7');
      expect(o.consumerId, '5');
      expect(o.consumerName, 'Mona Ali');
      expect(o.vendorName, 'Tech Store');
      expect(o.vendorId, '3');
      expect(o.status, OrderStatus.deliveryFailed);
      expect(o.paymentMethod, PaymentMethod.cashOnDelivery);
      expect(o.consumerPhone, '01012345678');
      expect(o.deliveryAddress.latitude, 30.0444);
      expect(o.deliveryAddress.longitude, 31.2357);
      expect(o.subtotal, 17001.0);
      expect(o.shippingCost, 60.0);
      expect(o.total, 17061.0);
      expect(o.courierId, '9');
      expect(o.cancelReason, 'Buyer unreachable');
      expect(o.cancelledBy, OrderCanceller.vendor);
      expect(o.isReviewed, isTrue);
      expect(o.createdAt, DateTime.parse('2026-10-20T10:30:00Z'));

      final item = o.items.single;
      expect(item.id, '11');
      expect(item.listingId, '42');
      expect(item.listingName, 'Used iPhone 12');
      expect(item.listingImage, 'https://cdn.test/a.jpg');
      expect(item.quantity, 2);
      expect(item.price, 8500.5);
      expect(item.total, 17001.0);
      expect(item.attributes, [
        (key: 'Color', value: 'Blue'),
        (key: 'Storage', value: '128GB'),
      ]);
    }, skip: skipMock);

    test('nullables absent: optional fields stay null, status 6 parses',
        () async {
      final ds = _ds(_envelope([
        {
          'id': 8,
          'buyerUserId': 5,
          'buyerName': 'Mona Ali',
          'vendorName': 'Tech Store',
          'vendorId': 3,
          'status': 6,
          'payment': 'cod',
          'phone': '',
          'latitude': 0,
          'longitude': 0,
          'subtotal': 100,
          'shipping': 0,
          'total': 100,
          'isReviewed': false,
          'createdAt': '2026-10-21T08:00:00Z',
          'items': [
            {
              'id': 12,
              'orderId': 8,
              'listingId': 43,
              'titleSnapshot': 'Desk',
              'priceSnapshot': 100,
              'imageUrls': ['https://cdn.test/d.jpg'],
              'qty': 1,
              'unitPrice': 100,
            },
          ],
        },
      ]));
      final o =
          (await ds.getVendorOrders(vendorId: '3', page: 1, pageSize: 20))
              .single;

      expect(o.status, OrderStatus.deliveryFailed);
      expect(o.courierId, isNull);
      expect(o.cancelReason, isNull);
      expect(o.cancelledBy, isNull);
      expect(o.isReviewed, isFalse);
      expect(o.deliveryAddress.latitude, isNull);
      expect(o.deliveryAddress.longitude, isNull);
      expect(o.shippingCost, 0);
      expect(o.total, 100);
      expect(o.items.single.attributes, isEmpty);
      expect(o.items.single.price, 100);
    }, skip: skipMock);

    test('all VendorOrdersResponseDto summary fields reach OrderStatsEntity',
        () async {
      final ds = _ds(_envelope(const []));
      final s = await ds.getVendorOrderStats(vendorId: '3');

      expect(s.totalCount, 12);
      expect(s.pendingCount, 3);
      expect(s.activeCount, 4); // confirmedCount
      expect(s.totalRevenue, 25000.75);
      expect(s.outstandingBalance, 120.5);
      expect(s.warnThresholdEgp, 100.0);
      expect(s.pauseThresholdEgp, 500.0);
      expect(s.exceedsWarnThreshold, isTrue);
      expect(s.exceedsPauseThreshold, isFalse);
      expect(s.commissionValueOnOrder, 15.0);
    }, skip: skipMock);
  });
}
