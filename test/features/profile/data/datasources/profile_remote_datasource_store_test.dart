import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';

class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;
  final captured = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured.add(options);
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

DioException _badResponse(RequestOptions options, int statusCode) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: statusCode),
    );

Map<String, dynamic> _listingJson({
  int id = 7,
  int userId = 42,
  String title = 'Desk Lamp',
  String storeName = 'Tech Hub',
  String userName = 'Ahmed Vendor',
  num price = 250,
  String category = 'Home',
}) => {
  'id': id,
  'titleEn': title,
  'title': title,
  'description': 'A lamp',
  'price': price,
  'status': 2,
  'userId': userId,
  'userName': userName,
  'userAvatar': 'https://example.test/avatar.jpg',
  'storeName': storeName,
  'imageUrls': ['https://example.test/lamp.jpg'],
  'category': category,
  'location': 'Cairo',
};

void main() {
  late ProfileRemoteDataSourceImpl datasource;
  late _ScriptedInterceptor interceptor;

  ProfileRemoteDataSourceImpl datasourceFor(
    Object? Function(RequestOptions options) respond,
  ) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    interceptor = _ScriptedInterceptor(respond);
    d.interceptors.add(interceptor);
    return ProfileRemoteDataSourceImpl(d);
  }

  final skipMock = MockConfig.useMock
      ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
      : false;

  group('getVendorStoreProfile', () {
    test(
      'builds the store head from GET /api/listings filtered by userId',
      () async {
        datasource = datasourceFor(
          (_) => {
            'items': [
              _listingJson(userId: 99, storeName: 'Other'),
              _listingJson(),
            ],
          },
        );

        final result = await datasource.getVendorStoreProfile('42');

        expect(interceptor.captured.single.path, ApiEndpoints.apiListings);
        expect(result.user.id, '42');
        expect(result.user.storeName, 'Tech Hub');
        expect(result.user.name, 'Tech Hub');
        expect(result.user.avatarUrl, 'https://example.test/avatar.jpg');
        expect(result.user.role, UserRole.vendor);
        expect(result.storeActiveListings, 1);
      },
      skip: skipMock,
    );

    test(
      'falls back to GET /api/home when nearby listings miss the seller',
      () async {
        datasource = datasourceFor((options) {
          if (options.path == ApiEndpoints.home) {
            return {
              'newArrivals': [_listingJson()],
              'recommendedForYou': <dynamic>[],
              'hotDeals': <dynamic>[],
            };
          }
          return {'items': <dynamic>[]};
        });

        final result = await datasource.getVendorStoreProfile('42');

        expect(interceptor.captured.map((e) => e.path), [
          ApiEndpoints.apiListings,
          ApiEndpoints.home,
        ]);
        expect(result.user.storeName, 'Tech Hub');
        expect(result.storeActiveListings, 1);
      },
      skip: skipMock,
    );

    test(
      'still returns a store head when the seller has no public listings',
      () async {
        datasource = datasourceFor((options) {
          if (options.path == ApiEndpoints.home) {
            return {
              'newArrivals': <dynamic>[],
              'recommendedForYou': <dynamic>[],
              'hotDeals': <dynamic>[],
            };
          }
          return {'items': <dynamic>[]};
        });

        final result = await datasource.getVendorStoreProfile('42');

        expect(result.user.id, '42');
        expect(result.user.name, '42');
        expect(result.storeActiveListings, 0);
      },
      skip: skipMock,
    );
  });

  group('fetchVendorStoreListings', () {
    test(
      'returns that seller\'s catalog rows and pages them locally',
      () async {
        datasource = datasourceFor(
          (_) => {
            'items': [
              _listingJson(),
              _listingJson(id: 8, title: 'Chair', price: 400),
              _listingJson(userId: 99, id: 9, title: 'Other vendor'),
            ],
          },
        );

        final page0 = await datasource.fetchVendorStoreListings(
          sellerId: '42',
          page: 0,
          pageSize: 1,
        );
        final page1 = await datasource.fetchVendorStoreListings(
          sellerId: '42',
          page: 1,
          pageSize: 1,
        );

        expect(page0, hasLength(1));
        expect(page0.first.title, 'Desk Lamp');
        expect(page0.first.vendorId, '42');
        expect(page1.single.title, 'Chair');
        expect(
          interceptor.captured.where((e) => e.path == ApiEndpoints.apiListings),
          hasLength(1),
        );
      },
      skip: skipMock,
    );

    test('filters by categoryLabel after the catalog fetch', () async {
      datasource = datasourceFor(
        (_) => {
          'items': [
            _listingJson(),
            _listingJson(id: 8, title: 'Phone', category: 'Electronics'),
          ],
        },
      );

      final result = await datasource.fetchVendorStoreListings(
        sellerId: '42',
        categoryLabel: 'Home',
        page: 0,
        pageSize: 10,
      );

      expect(result, hasLength(1));
      expect(result.single.title, 'Desk Lamp');
    }, skip: skipMock);

    test('falls back to GET /api/home when nearby listings 500', () async {
      datasource = datasourceFor((options) {
        if (options.path == ApiEndpoints.home) {
          return {
            'newArrivals': [_listingJson()],
            'recommendedForYou': <dynamic>[],
            'hotDeals': <dynamic>[],
          };
        }
        return _badResponse(options, 500);
      });

      final result = await datasource.getVendorStoreProfile('42');
      final listings = await datasource.fetchVendorStoreListings(
        sellerId: '42',
        page: 0,
        pageSize: 10,
      );

      expect(result.user.storeName, 'Tech Hub');
      expect(listings, hasLength(1));
      expect(listings.single.title, 'Desk Lamp');
    }, skip: skipMock);
  });
}
