import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/governments/data/datasources/government_remote_datasource.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, ApiEndpoints.governments);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('parses the live bare array of governorates', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _Adapter([
        {'id': 16, 'nameEn': 'Cairo', 'nameAr': 'القاهرة'},
        {'id': 15, 'nameEn': 'Alexandria', 'nameAr': 'الإسكندرية'},
      ]);
    final ds = GovernmentRemoteDataSourceImpl(dio);

    final result = await ds.getGovernments(page: 1, pageSize: 100);
    expect(result.items.map((e) => e.nameEn), ['Cairo', 'Alexandria']);
    expect(result.totalCount, 2);
  });

  test('still parses the older items envelope', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _Adapter({
        'items': [
          {'id': 16, 'nameEn': 'Cairo', 'nameAr': 'القاهرة'},
        ],
        'totalCount': 1,
      });
    final ds = GovernmentRemoteDataSourceImpl(dio);

    final result = await ds.getGovernments(page: 1, pageSize: 100);
    expect(result.items.single.nameEn, 'Cairo');
    expect(result.totalCount, 1);
  });
}
