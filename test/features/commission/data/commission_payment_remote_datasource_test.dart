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

/// Answers each request from [answer]: a non-2xx status rejects like Dio does.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this.answer);

  final (int, dynamic) Function(RequestOptions options) answer;
  final requests = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final (status, data) = answer(options);
    final response = Response(
      requestOptions: options,
      statusCode: status,
      data: data,
    );
    if (status >= 400) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    } else {
      handler.resolve(response);
    }
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

    test(
      'getPayToAccounts reads the by-key route first',
      () async {
        final interceptor = _RecordingInterceptor({
          'key': 'commission_payment_accounts',
          'value': '{"InstaPay":"xstore@instapay"}',
        });
        final dio = Dio()..interceptors.add(interceptor);

        final accounts = await CommissionPaymentRemoteDataSource(
          dio,
        ).getPayToAccounts();

        final request = interceptor.requests.single;
        expect(request.method, 'GET');
        expect(
          request.path,
          ApiEndpoints.generalSettingByKey('commission_payment_accounts'),
        );
        expect(
          request.path,
          endsWith('/general-settings/by-key/commission_payment_accounts'),
        );
        expect(accounts, {CommissionPaymentMethod.instaPay: 'xstore@instapay'});
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );

    for (final status in [404, 405]) {
      test(
        'getPayToAccounts falls back to ?search= when by-key is $status',
        () async {
          // Shape of the live GET /api/general-settings?search=… page.
          final interceptor = _ScriptedInterceptor(
            (options) => options.path.contains('by-key')
                ? (status, null)
                : (
                    200,
                    {
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
                    },
                  ),
          );
          final dio = Dio()..interceptors.add(interceptor);

          final accounts = await CommissionPaymentRemoteDataSource(
            dio,
          ).getPayToAccounts();

          expect(interceptor.requests, hasLength(2));
          final fallback = interceptor.requests.last;
          expect(fallback.path, ApiEndpoints.generalSettings);
          expect(fallback.queryParameters, {
            'search': 'commission_payment_accounts',
          });
          expect(accounts, {
            CommissionPaymentMethod.instaPay: 'xstore@instapay',
          });
        },
        skip: MockConfig.useMock
            ? 'MOCK=true short-circuits the request'
            : null,
      );
    }

    test(
      'getPayToAccounts falls back to ?search= when by-key is unparseable',
      () async {
        final interceptor = _ScriptedInterceptor(
          (options) => options.path.contains('by-key')
              ? (200, 'not a setting')
              : (
                  200,
                  {
                    'items': [
                      {
                        'key': 'commission_payment_accounts',
                        'value': '{"VodafoneCash":"01000000000"}',
                      },
                    ],
                  },
                ),
        );
        final dio = Dio()..interceptors.add(interceptor);

        final accounts = await CommissionPaymentRemoteDataSource(
          dio,
        ).getPayToAccounts();

        expect(interceptor.requests, hasLength(2));
        expect(accounts, {CommissionPaymentMethod.vodafoneCash: '01000000000'});
      },
      skip: MockConfig.useMock ? 'MOCK=true short-circuits the request' : null,
    );

    test(
      'getPayToAccounts does not fall back on a server error',
      () async {
        final interceptor = _ScriptedInterceptor((_) => (500, null));
        final dio = Dio()..interceptors.add(interceptor);

        await expectLater(
          CommissionPaymentRemoteDataSource(dio).getPayToAccounts(),
          throwsA(isA<AppException>()),
        );
        expect(interceptor.requests, hasLength(1));
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
