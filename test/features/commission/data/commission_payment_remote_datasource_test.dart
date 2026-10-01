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
  // PROPOSED contract — see
  // docs_business/backend/11_COMMISSION_PAYMENT_REQUESTS_HANDOFF.md.
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
          'amountEgp': '250.5',
        });
        expect(form.files.single.key, 'receiptImage');
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
      'getPayToAccounts reads the commission_payment_accounts setting',
      () async {
        // Shape of the live GET /api/general-settings?search=… page.
        final interceptor = _RecordingInterceptor({
          'items': [
            {
              'id': 4,
              'key': 'commission_payment_accounts_old',
              'value': '{"InstaPay":"old@instapay"}',
            },
            {
              'id': 5,
              'key': 'commission_payment_accounts',
              'value': '{"InstaPay":"xstore@instapay"}',
              'dataType': 'Json',
            },
          ],
          'totalCount': 2,
          'page': 1,
          'pageSize': 20,
          'totalPages': 1,
        });
        final dio = Dio()..interceptors.add(interceptor);

        final accounts = await CommissionPaymentRemoteDataSource(
          dio,
        ).getPayToAccounts();

        final request = interceptor.requests.single;
        expect(request.path, ApiEndpoints.generalSettings);
        expect(request.queryParameters, {
          'search': 'commission_payment_accounts',
        });
        expect(accounts, {CommissionPaymentMethod.instaPay: 'xstore@instapay'});
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );
  });

  group('parsePayToAccounts', () {
    const expected = {
      CommissionPaymentMethod.instaPay: 'xstore@instapay',
      CommissionPaymentMethod.vodafoneCash: '01000000000',
    };
    const raw = {'InstaPay': 'xstore@instapay', 'VodafoneCash': '01000000000'};

    test('accepts a bare object', () {
      expect(parsePayToAccounts(raw), expected);
    });

    test('accepts a JSON string inside a setting row inside the envelope', () {
      expect(
        parsePayToAccounts({
          'data': {
            'value':
                '{"InstaPay":"xstore@instapay","VodafoneCash":"01000000000"}',
          },
        }),
        expected,
      );
    });

    test('drops blank values and unknown methods', () {
      expect(
        parsePayToAccounts({...raw, 'OrangeCash': '  ', 'Fawry': '123'}),
        expected,
      );
    });

    test('reads malformed values as no accounts', () {
      expect(parsePayToAccounts('{not json'), isEmpty);
      expect(parsePayToAccounts(null), isEmpty);
      expect(parsePayToAccounts(['InstaPay']), isEmpty);
    });

    test('a search page without the exact key reads as not configured', () {
      expect(
        parsePayToAccounts({
          'items': [
            {
              'key': 'commission_payment_accounts_v2',
              'value': '{"InstaPay":"x"}',
            },
          ],
        }),
        isEmpty,
      );
      expect(parsePayToAccounts({'items': []}), isEmpty);
    });
  });

  test('every method round-trips through its wire name', () {
    for (final method in CommissionPaymentMethod.values) {
      expect(CommissionPaymentMethod.fromWire(method.wireName), method);
    }
    expect(CommissionPaymentMethod.fromWire('Fawry'), isNull);
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
