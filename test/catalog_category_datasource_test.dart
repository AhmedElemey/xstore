import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/catalog_categories/data/datasources/catalog_category_remote_datasource.dart';
import 'package:xstore/features/catalog_categories/data/models/catalog_category_model.dart';
import 'package:xstore/features/listing/presentation/utils/catalog_category_tree.dart';

/// Bare-list body matching live `GET /api/categories` (2026-08-15).
const _liveCategoriesJson = '''
[
  {
    "id": 7,
    "nameEn": "Automotive",
    "nameAr": "السيارات",
    "imageUrl": "http://example.test/car",
    "isActive": true,
    "parentId": null,
    "children": [
      {
        "id": 32,
        "nameEn": "Parts",
        "nameAr": "قطع غيار",
        "imageUrl": null,
        "isActive": true,
        "parentId": 7,
        "children": []
      },
      {
        "id": 33,
        "nameEn": "Accessories",
        "nameAr": "الإكسسوارات",
        "imageUrl": null,
        "isActive": true,
        "parentId": 7,
        "children": []
      }
    ]
  },
  {
    "id": 4,
    "nameEn": "Beauty",
    "nameAr": "الجمال",
    "imageUrl": null,
    "isActive": true,
    "parentId": null,
    "children": [
      {
        "id": 23,
        "nameEn": "Skincare",
        "nameAr": "العناية بالبشرة",
        "imageUrl": null,
        "isActive": true,
        "parentId": 4,
        "children": []
      }
    ]
  }
]
''';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, {this.contentType = 'application/json'});

  final String body;
  final String contentType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, ApiEndpoints.catalogCategories);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final skipMock = MockConfig.useMock
      ? 'MockConfig.useMock short-circuits Dio'
      : false;

  test(
    'parses live-shaped JSON list into tree with nested children',
    skip: skipMock,
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _Adapter(_liveCategoriesJson);
      final ds = CatalogCategoryRemoteDataSourceImpl(dio);

      final models = await ds.getCategories();
      expect(models.map((e) => e.nameEn), ['Automotive', 'Beauty']);
      expect(
        models.first.children.map((e) => e.nameEn),
        ['Parts', 'Accessories'],
      );

      final all = models.map((e) => e.toEntity()).toList();
      expect(
        subcategoriesOf(all, 7).map((e) => e.name.en),
        ['Parts', 'Accessories'],
      );
      expect(subcategoriesOf(all, 4).single.name.en, 'Skincare');
    },
  );

  test(
    'unwraps a JSON string body when content-type is not json',
    skip: skipMock,
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _Adapter(
          _liveCategoriesJson,
          contentType: 'text/plain',
        );
      final ds = CatalogCategoryRemoteDataSourceImpl(dio);

      final models = await ds.getCategories();
      expect(models, isNotEmpty);
      expect(models.first.nameEn, 'Automotive');
      expect(models.first.children, isNotEmpty);
    },
  );

  test(
    'skips a malformed row instead of emptying the catalog',
    skip: skipMock,
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _Adapter(
          jsonEncode([
            {
              'id': 7,
              'nameEn': 'Automotive',
              'nameAr': 'السيارات',
              'children': <dynamic>[],
            },
            'not-an-object',
            {
              'id': 4,
              'nameEn': 'Beauty',
              'nameAr': 'الجمال',
              'children': <dynamic>[],
            },
          ]),
        );
      final ds = CatalogCategoryRemoteDataSourceImpl(dio);

      final models = await ds.getCategories();
      expect(models.map((e) => e.id), [7, 4]);
    },
  );
}
