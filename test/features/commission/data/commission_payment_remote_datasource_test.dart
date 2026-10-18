import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/commission/data/datasources/commission_payment_remote_datasource.dart';
import 'package:xstore/features/commission/domain/entities/commission_payment_method.dart';

/// Records each request and answers with [responseData] without touching
/// the network.
class _RecordingInterceptor extends Interceptor {
  _RecordingInterceptor([this.responseData]);

  final dynamic responseData;
  final requests = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response(requestOptions: options, statusCode: 201, data: responseData),
    );
  }
}

void main() {
  // Field names are from the backend Postman collection (v10).
  group('CommissionPaymentRemoteDataSource', () {
    late Directory tmpDir;

    setUp(() async {
      tmpDir = await Directory.systemTemp.createTemp('commission_payment');
    });

    tearDown(() async {
      if (tmpDir.existsSync()) await tmpDir.delete(recursive: true);
    });

    test(
      'submitPayment posts method, amount and the receipt as multipart',
      () async {
        final receipt = File('${tmpDir.path}/receipt.jpg')
          ..writeAsBytesSync(const [0, 1, 2, 3]);
        final interceptor = _RecordingInterceptor({'id': 1});
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..interceptors.add(interceptor);

        await CommissionPaymentRemoteDataSource(dio).submitPayment(
          method: CommissionPaymentMethod.vodafoneCash,
          amountEgp: 250.5,
          receiptImagePath: receipt.path,
        );

        final request = interceptor.requests.single;
        expect(request.method, 'POST');
        expect(request.path, ApiEndpoints.vendorCommissionPayments);
        final form = request.data as FormData;
        expect(Map.fromEntries(form.fields), {
          'method': 'VodafoneCash',
          'amountEgp': '250.50',
        });
        expect(form.files.single.key, 'receipt');
        expect(form.files.where((f) => f.key == 'receiptImage'), isEmpty);
        expect(form.files.single.value.filename, 'receipt.jpg');
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );

    test(
      'submitPayment fails without a request when the receipt file is gone',
      () async {
        final interceptor = _RecordingInterceptor();
        final dio = Dio()..interceptors.add(interceptor);

        await expectLater(
          CommissionPaymentRemoteDataSource(dio).submitPayment(
            method: CommissionPaymentMethod.instaPay,
            amountEgp: 100,
            receiptImagePath: '${tmpDir.path}/evicted.jpg',
          ),
          throwsA(isA<AppException>()),
        );
        expect(interceptor.requests, isEmpty);
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );

    test(
      'submitPayment throws on a 2xx isSuccess:false envelope',
      () async {
        final receipt = File('${tmpDir.path}/receipt.jpg')
          ..writeAsBytesSync(const [0, 1, 2, 3]);
        final dio = Dio()
          ..interceptors.add(
            _RecordingInterceptor({
              'isSuccess': false,
              'errorEn': 'Amount exceeds balance',
            }),
          );

        await expectLater(
          CommissionPaymentRemoteDataSource(dio).submitPayment(
            method: CommissionPaymentMethod.instaPay,
            amountEgp: 100,
            receiptImagePath: receipt.path,
          ),
          throwsA(isA<ServerException>()),
        );
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );
  });

  test('every method round-trips through its wire name', () {
    for (final method in CommissionPaymentMethod.values) {
      expect(CommissionPaymentMethod.fromWire(method.wireName), method);
    }
    expect(CommissionPaymentMethod.fromWire('Fawry'), isNull);
  });

  test('fromWire accepts any casing and the C# enum codes', () {
    expect(
      CommissionPaymentMethod.fromWire('vodafonecash'),
      CommissionPaymentMethod.vodafoneCash,
    );
    expect(
      CommissionPaymentMethod.fromWire(' INSTAPAY '),
      CommissionPaymentMethod.instaPay,
    );
    expect(
      CommissionPaymentMethod.fromWire('1'),
      CommissionPaymentMethod.instaPay,
    );
    expect(
      CommissionPaymentMethod.fromWire('2'),
      CommissionPaymentMethod.vodafoneCash,
    );
    expect(
      CommissionPaymentMethod.fromWire('3'),
      CommissionPaymentMethod.orangeCash,
    );
    expect(
      CommissionPaymentMethod.fromWire('4'),
      CommissionPaymentMethod.etisalatCash,
    );
    expect(CommissionPaymentMethod.fromWire('0'), isNull);
    expect(CommissionPaymentMethod.fromWire('5'), isNull);
    expect(CommissionPaymentMethod.fromWire(null), isNull);
    expect(CommissionPaymentMethod.vodafoneCash.wireName, 'VodafoneCash');
  });

  test('payment routes are vendor-only', () {
    expect(isVendorRestrictedRoute(AppRoutes.commissionPayment), isTrue);
    expect(
      isVendorRestrictedRoute(
        AppRoutes.commissionPaymentReceiptPath('InstaPay'),
      ),
      isTrue,
    );
  });
}
