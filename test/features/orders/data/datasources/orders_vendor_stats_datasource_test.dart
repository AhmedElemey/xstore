import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';

/// Resolves every request with a scripted value instead of hitting the
/// network — same approach as the catalog-category datasource tests.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
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
  late Dio dio;
  late OrdersRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  final skipMock = MockConfig.useMock
      ? 'MockConfig.useMock short-circuits Dio'
      : false;

  group('getVendorOrderStats (live Dio path)', () {
    test(
      'reads camelCase commission and counts from a flat envelope',
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {
            'orders': <dynamic>[],
            'totalCount': 4,
            'pendingCount': 1,
            'confirmedCount': 2,
            'totalRevenue': 1500.5,
            'commissionValueOnOrder': 10,
            'warnThresholdEgp': 100,
            'pauseThresholdEgp': 200,
            'exceedsWarnThreshold': true,
            'exceedsPauseThreshold': false,
          };
        });
        datasource = OrdersRemoteDataSourceImpl(dio);

        final stats = await datasource.getVendorOrderStats(vendorId: '7');

        expect(captured?.path, ApiEndpoints.vendorOrders);
        expect(stats.totalCount, 4);
        expect(stats.pendingCount, 1);
        expect(stats.activeCount, 2);
        expect(stats.totalRevenue, 1500.5);
        expect(stats.commissionValueOnOrder, 10);
        expect(stats.warnThresholdEgp, 100);
        expect(stats.pauseThresholdEgp, 200);
        expect(stats.exceedsWarnThreshold, isTrue);
        expect(stats.exceedsPauseThreshold, isFalse);
      },
      skip: skipMock,
    );

    test(
      'unwraps a nested {data} envelope and string/PascalCase numbers',
      () async {
        dio = buildDio(
          (_) => {
            'isSuccess': true,
            'data': {
              'Orders': <dynamic>[],
              'TotalCount': '3',
              'PendingCount': '1',
              'ConfirmedCount': '0',
              'TotalRevenue': '99.5',
              'CommissionValueOnOrder': '10.00',
              'WarnThresholdEgp': '100',
              'PauseThresholdEgp': '200',
              'ExceedsWarnThreshold': true,
            },
          },
        );
        datasource = OrdersRemoteDataSourceImpl(dio);

        final stats = await datasource.getVendorOrderStats(vendorId: '7');

        expect(stats.totalCount, 3);
        expect(stats.pendingCount, 1);
        expect(stats.commissionValueOnOrder, 10);
        expect(stats.warnThresholdEgp, 100);
        expect(stats.exceedsWarnThreshold, isTrue);
      },
      skip: skipMock,
    );

    test(
      'keeps a seeded 0 commission so the provider can fall back',
      () async {
        dio = buildDio(
          (_) => {
            'orders': <dynamic>[],
            'totalCount': 0,
            'commissionValueOnOrder': 0,
          },
        );
        datasource = OrdersRemoteDataSourceImpl(dio);

        final stats = await datasource.getVendorOrderStats(vendorId: '7');

        expect(stats.commissionValueOnOrder, 0);
      },
      skip: skipMock,
    );
  });
}
