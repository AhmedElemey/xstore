import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_auth_headers.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/general_settings/data/datasources/general_settings_remote_datasource.dart';
import 'package:xstore/features/general_settings/domain/entities/app_settings.dart';

import '../../helpers/fake_general_settings.dart';

class _Scripted extends Interceptor {
  _Scripted(this.answer);
  final dynamic Function(RequestOptions) answer;
  final requests = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: answer(options)),
    );
  }
}

void main() {
  group('AppSettings parsing', () {
    test('keeps every key of the live sample and parses by dataType', () {
      final s = AppSettings.fromItems(
        generalSettingsSampleBody['items']! as List,
      );
      expect(s.string('instapay_handle'), '01019816854');
      expect(s.string('vodafone_cash_handle'), '01019816854');
      expect(s.string('orange_cash_handle'), '01019816854');
      expect(s.string('etisalat_cash_handle'), '01019816854');
      expect(s.boolean('test'), isFalse);
      expect(s.string('test'), isNull);
      expect(s.raw('test'), 'false');
      expect(s.raw('missing'), isNull);
    });

    test(
      'Boolean is case-insensitive; Number/Decimal give num; Json decodes',
      () {
        final s = AppSettings.fromItems(const [
          {'key': 'a', 'value': 'TRUE', 'dataType': 'Boolean'},
          {'key': 'b', 'value': '12', 'dataType': 'Number'},
          {'key': 'c', 'value': '1.5', 'dataType': 'Decimal'},
          {'key': 'd', 'value': '{"x":[1,2]}', 'dataType': 'Json'},
          {'key': 'e', 'value': 'raw', 'dataType': 'Mystery'},
          {'key': 'f', 'value': '{bad', 'dataType': 'Json'},
          {'key': 'g', 'value': 'nope', 'dataType': 'Int'},
        ]);
        expect(s.boolean('a'), isTrue);
        expect(s.number('b'), 12);
        expect(s.number('c'), 1.5);
        expect(s.value('d'), {
          'x': [1, 2],
        });
        expect(s.value('e'), 'raw');
        expect(s.value('f'), '{bad');
        expect(s.number('g'), isNull);
        expect(s.raw('g'), 'nope');
      },
    );

    test('round-trips through the cache JSON and compares by content', () {
      final s = AppSettings.fromItems(
        generalSettingsSampleBody['items']! as List,
      );
      final back = AppSettings.tryFromJson(s.toJson());
      expect(back, s);
      expect(back.hashCode, s.hashCode);
      expect(
        AppSettings.fromItems(const [
          {'key': 'test', 'value': 'true', 'dataType': 'Boolean'},
        ]),
        isNot(
          AppSettings.fromItems(const [
            {'key': 'test', 'value': 'false', 'dataType': 'Boolean'},
          ]),
        ),
      );
      expect(AppSettings.tryFromJson('{not json'), isNull);
      expect(AppSettings.tryFromJson(null), isNull);
    });

    test(
      'a stored [] is a valid empty cache; unparseable rows are corrupt',
      () {
        expect(AppSettings.tryFromJson('[]'), AppSettings.empty);
        expect(AppSettings.tryFromJson('[1,2,3]'), isNull);
        expect(AppSettings.tryFromJson('[{"nokey":1}]'), isNull);
        expect(
          AppSettings.tryFromJson('[1,{"key":"a","value":"b"}]')!.raw('a'),
          'b',
        );
      },
    );
  });

  group('GeneralSettingsRemoteDataSource', () {
    final skip = MockConfig.useMock
        ? 'MOCK=true returns fixtures without a request'
        : null;

    test('reads page 1 with pageSize 20 and parses the live sample', () async {
      final interceptor = _Scripted((_) => generalSettingsSampleBody);
      final dio = Dio()..interceptors.add(interceptor);

      final s = await GeneralSettingsRemoteDataSource(dio).fetchAll();

      final request = interceptor.requests.single;
      expect(request.method, 'GET');
      expect(request.path, ApiEndpoints.generalSettings);
      expect(request.queryParameters, {'page': 1, 'pageSize': 20});
      expect(s.string('instapay_handle'), '01019816854');
      expect(s.boolean('test'), isFalse);
    }, skip: skip);

    test(
      'fetches the remaining pages when totalPages > 1 and merges',
      () async {
        final interceptor = _Scripted((o) {
          final page = o.queryParameters['page'] as int;
          return {
            'items': [
              {'key': 'k$page', 'value': 'v$page', 'dataType': 'String'},
            ],
            'totalPages': 3,
            'page': page,
          };
        });
        final dio = Dio()..interceptors.add(interceptor);

        final s = await GeneralSettingsRemoteDataSource(dio).fetchAll();

        expect(interceptor.requests.map((r) => r.queryParameters['page']), [
          1,
          2,
          3,
        ]);
        expect([s.raw('k1'), s.raw('k2'), s.raw('k3')], ['v1', 'v2', 'v3']);
      },
      skip: skip,
    );

    test('an unexpected body is an error, not an empty set', () async {
      final dio = Dio()..interceptors.add(_Scripted((_) => 'oops'));
      await expectLater(
        GeneralSettingsRemoteDataSource(dio).fetchAll(),
        throwsA(isA<FormatException>()),
      );
    }, skip: skip);

    test(
      'an unusable non-empty items is an error; empty items is valid',
      () async {
        for (final items in [
          [1, 'x', null],
          [
            {'nokey': 1},
          ],
        ]) {
          final dio = Dio()
            ..interceptors.add(
              _Scripted((_) => {'items': items, 'totalPages': 1}),
            );
          await expectLater(
            GeneralSettingsRemoteDataSource(dio).fetchAll(),
            throwsA(isA<FormatException>()),
            reason: '$items',
          );
        }
        final dio = Dio()
          ..interceptors.add(_Scripted((_) => {'items': [], 'totalPages': 1}));
        expect(
          await GeneralSettingsRemoteDataSource(dio).fetchAll(),
          AppSettings.empty,
        );
      },
      skip: skip,
    );

    test('caps a huge totalPages', () async {
      final interceptor = _Scripted(
        (o) => {
          'items': [
            {'key': 'k${o.queryParameters['page']}', 'value': 'v'},
          ],
          'totalPages': 300,
        },
      );
      final dio = Dio()..interceptors.add(interceptor);

      await GeneralSettingsRemoteDataSource(dio).fetchAll();

      expect(
        interceptor.requests,
        hasLength(GeneralSettingsRemoteDataSource.maxPages),
      );
    }, skip: skip);

    test('is a standalone request and forwards the cancel token', () async {
      final interceptor = _Scripted((_) => generalSettingsSampleBody);
      final dio = Dio()..interceptors.add(interceptor);
      final token = CancelToken();

      await GeneralSettingsRemoteDataSource(dio).fetchAll(cancelToken: token);

      final request = interceptor.requests.single;
      expect(request.extra[ApiAuthHeaders.standaloneKey], isTrue);
      expect(request.cancelToken, same(token));
    }, skip: skip);
  });
}
