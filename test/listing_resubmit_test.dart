import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';

class _CapturingInterceptor extends Interceptor {
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'id': 7,
          'titleEn': 'x',
          'title': 'x',
          'description': 'x',
          'price': 42,
          'status': 1,
        },
      ),
    );
  }
}

void main() {
  group('ListingRemoteDataSource resubmitListing', () {
    late Dio dio;
    late _CapturingInterceptor interceptor;
    late ListingRemoteDataSourceImpl datasource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      interceptor = _CapturingInterceptor();
      dio.interceptors.add(interceptor);
      datasource = ListingRemoteDataSourceImpl(dio);
    });

    test('PUTs a plain JSON body to /listings/{id}/resubmit, not multipart',
        () async {
      await datasource.resubmitListing(id: '7', newPrice: 129.5);

      final options = interceptor.captured!;
      expect(options.method, 'PUT');
      expect(options.path, '/api/listings/7/resubmit');
      expect(options.data, isA<Map<String, dynamic>>());
      expect(options.data, {'newPrice': 129.5});
    });
  });

  group('ListingRemoteDataSource deactivateListing', () {
    late Dio dio;
    late _CapturingInterceptor interceptor;
    late ListingRemoteDataSourceImpl datasource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      interceptor = _CapturingInterceptor();
      dio.interceptors.add(interceptor);
      datasource = ListingRemoteDataSourceImpl(dio);
    });

    test('PUTs to /listings/{id}/deactivate with no body', () async {
      await datasource.deactivateListing('7');

      final options = interceptor.captured!;
      expect(options.method, 'PUT');
      expect(options.path, '/api/listings/7/deactivate');
      expect(options.data, isNull);
    });
  });

  group('ListingModel rejectionReason tolerant parsing', () {
    test('reads the confirmed admin write key', () {
      final model = ListingModel.fromJson({
        'id': 1,
        'titleEn': 'x',
        'title': 'x',
        'description': 'x',
        'price': 10,
        'rejectionReason': 'Blurry photos',
      });
      expect(model.rejectionReason, 'Blurry photos');
    });

    test('falls back through candidate keys', () {
      final model = ListingModel.fromJson({
        'id': 1,
        'titleEn': 'x',
        'title': 'x',
        'description': 'x',
        'price': 10,
        'reason': 'Missing category',
      });
      expect(model.rejectionReason, 'Missing category');
    });

    test('is null (not empty string) when no reason is present', () {
      final model = ListingModel.fromJson({
        'id': 1,
        'titleEn': 'x',
        'title': 'x',
        'description': 'x',
        'price': 10,
      });
      expect(model.rejectionReason, isNull);
    });
  });
}
