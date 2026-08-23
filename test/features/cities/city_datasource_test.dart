import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/cities/data/datasources/city_remote_datasource.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, ApiEndpoints.cities);
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
  test('parses the live bare array of cities', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _Adapter([
        {
          'id': 1,
          'nameEn': 'Cairo',
          'nameAr': 'القاهرة',
          'governorateId': 16,
        },
      ]);
    final ds = CityRemoteDataSourceImpl(dio);

    final result = await ds.getCities(page: 1, pageSize: 100);
    expect(result.items.single.nameEn, 'Cairo');
    expect(result.items.single.governorateId, 16);
    expect(result.totalCount, 1);
  });
}
