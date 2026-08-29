import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist datasource tests.
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

DioException _notFound(RequestOptions options) => DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 404),
    );

DioException _badResponse(RequestOptions options, int statusCode) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: statusCode),
    );

Map<String, dynamic> _populatedStoreJson() => {
      'user': {
        'id': 42,
        'fullName': 'Ahmed Vendor',
        'email': 'vendor@test.com',
        'phoneNumber': '01012345678',
        'roleName': 'Vendor',
        'storeName': 'Tech Hub',
        'avatarUrl': 'https://example.test/avatar.jpg',
      },
      'storeViewCount': 2400,
      'storeSaveCount': 89,
      'storeActiveListings': 18,
      'responseRatePercent': 91,
    };

Map<String, dynamic> _listingJson({
  int id = 7,
  String title = 'Desk Lamp',
  num price = 250,
}) =>
    {
      'id': id,
      'titleEn': title,
      'title': title,
      'description': 'A lamp',
      'price': price,
      'status': 2,
      'userId': 42,
      'imageUrls': ['https://example.test/lamp.jpg'],
      'category': 'Home',
    };

void main() {
  late Dio dio;
  late ProfileRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  group('getVendorStoreProfile', () {
    test(
      'GETs /users/{id}/store and parses a populated store head',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return _populatedStoreJson();
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        final result = await datasource.getVendorStoreProfile('v1');

        expect(captured!.method, 'GET');
        expect(captured!.path, '${ApiEndpoints.users}/v1/store');
        expect(result.user.id, '42');
        expect(result.user.name, 'Ahmed Vendor');
        expect(result.user.storeName, 'Tech Hub');
        expect(result.user.role, UserRole.vendor);
        expect(result.storeViewCount, 2400);
        expect(result.storeSaveCount, 89);
        expect(result.storeActiveListings, 18);
        expect(result.responseRatePercent, 91);
      },
    );

    test(
      'GET /users/{id}/store 404 throws instead of an empty fallback profile',
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
      () async {
        // Last-round QA (2026-08-29): this legacy route is not deployed.
        // A 404 is a real miss — callers must surface ErrorStateWidget, not
        // a blank shell built from a missing resource.
        dio = buildDio(_notFound);
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.getVendorStoreProfile('v1'),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test(
      'throws ServerException on an empty response body',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((_) => null);
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.getVendorStoreProfile('v1'),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('fetchVendorStoreListings', () {
    test(
      'GETs /users/{id}/listings with page/pageSize/category and parses items',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {
            'items': [
              _listingJson(),
              _listingJson(id: 8, title: 'Chair', price: 400),
            ],
          };
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        final result = await datasource.fetchVendorStoreListings(
          sellerId: 'v1',
          categoryLabel: 'Home',
          page: 0,
          pageSize: 10,
        );

        expect(captured!.method, 'GET');
        expect(captured!.path, '${ApiEndpoints.users}/v1/listings');
        expect(captured!.queryParameters, {
          'category': 'Home',
          'page': 0,
          'pageSize': 10,
        });
        expect(result, hasLength(2));
        expect(result.first.id, '7');
        expect(result.first.title, 'Desk Lamp');
        expect(result.first.price, 250);
        expect(result.first.vendorId, '42');
        expect(result.first.imageUrls, ['https://example.test/lamp.jpg']);
        expect(result.last.title, 'Chair');
      },
    );

    test(
      'omits the category query param when no filter is passed',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {'items': <dynamic>[]};
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        final result = await datasource.fetchVendorStoreListings(
          sellerId: 'v1',
          page: 1,
          pageSize: 20,
        );

        expect(captured!.queryParameters, {'page': 1, 'pageSize': 20});
        expect(result, isEmpty);
      },
    );

    test(
      'GET /users/{id}/listings 404 throws instead of an empty list',
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
      () async {
        // Same honesty rule as getVendorStoreProfile: a missing route is
        // not "this seller has zero listings."
        dio = buildDio(_notFound);
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.fetchVendorStoreListings(
            sellerId: 'v1',
            page: 0,
            pageSize: 10,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test(
      'maps a 500 response to a ServerException',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((options) => _badResponse(options, 500));
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.fetchVendorStoreListings(
            sellerId: 'v1',
            page: 0,
            pageSize: 10,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
