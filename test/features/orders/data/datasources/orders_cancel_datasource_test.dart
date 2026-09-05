import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final result = _respond(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

void main() {
  final skipMock = MockConfig.useMock
      ? 'MockConfig.useMock short-circuits Dio'
      : false;

  OrdersRemoteDataSourceImpl datasourceFor(
    Object? Function(RequestOptions options) respond,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(_ScriptedInterceptor(respond));
    return OrdersRemoteDataSourceImpl(dio);
  }

  group('cancelOrder (live Dio path)', () {
    test(
      'POSTs JSON {reason} so the request is application/json, not bodyless',
      () async {
        RequestOptions? captured;
        final ds = datasourceFor((options) {
          captured = options;
          return {
            'id': 2,
            'status': 'cancelled',
            'cancelReason': 'Changed my mind',
          };
        });

        final order = await ds.cancelOrder(
          orderId: '2',
          reason: 'Changed my mind',
          isVendorSession: false,
        );

        expect(captured?.method, 'POST');
        expect(captured?.path, ApiEndpoints.orderCancel('2'));
        expect(captured?.data, {'reason': 'Changed my mind'});
        expect(order.status, OrderStatus.cancelled);
        expect(order.cancelReason, 'Changed my mind');
      },
      skip: skipMock,
    );

    test(
      '2xx Result envelope does not refetch GET /orders/me/{id}',
      () async {
        final paths = <String>[];
        final ds = datasourceFor((options) {
          paths.add('${options.method} ${options.path}');
          if (options.method == 'GET') {
            fail('cancelled orders 404 on GET /me/{id}; do not refetch');
          }
          return {
            'isSuccess': true,
            'data': null,
          };
        });

        final order = await ds.cancelOrder(
          orderId: '2',
          reason: 'Changed my mind',
          isVendorSession: false,
        );

        expect(paths, ['POST ${ApiEndpoints.orderCancel('2')}']);
        expect(order.id, '2');
        expect(order.status, OrderStatus.cancelled);
        expect(order.cancelReason, 'Changed my mind');
      },
      skip: skipMock,
    );
  });
}
