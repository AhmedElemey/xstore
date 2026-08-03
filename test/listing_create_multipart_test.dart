import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

/// Captures the outgoing [FormData] before Dio serializes it onto the wire,
/// then resolves with a synthetic response so the datasource call completes
/// without touching the network.
class _CapturingInterceptor extends Interceptor {
  FormData? capturedFormData;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    capturedFormData = options.data as FormData;
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 201,
        data: <String, dynamic>{
          'id': 1,
          'titleEn': 'x',
          'title': 'x',
          'description': 'x',
          'price': 1,
        },
      ),
    );
  }
}

void main() {
  // CONFIRMED against the xStoreEcommerce Postman collection: POST/PUT
  // /api/listings are multipart/form-data, not flat JSON. This guards that
  // contract (array-style Attributes[i].Key/Value, inline imageFiles) so a
  // future refactor can't silently regress back to a JSON body.
  group('ListingRemoteDataSource createListing multipart contract', () {
    late Dio dio;
    late _CapturingInterceptor interceptor;
    late ListingRemoteDataSourceImpl datasource;
    late Directory tmpDir;

    setUp(() async {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      interceptor = _CapturingInterceptor();
      dio.interceptors.add(interceptor);
      datasource = ListingRemoteDataSourceImpl(dio);
      tmpDir = await Directory.systemTemp.createTemp('listing_multipart_test');
    });

    tearDown(() async {
      if (tmpDir.existsSync()) {
        await tmpDir.delete(recursive: true);
      }
    });

    test('sends text fields, indexed attributes, and inline image files', () async {
      final photo = File('${tmpDir.path}/photo1.jpg')
        ..writeAsBytesSync(const [0, 1, 2, 3]);

      await datasource.createListing(
        titleEn: 'New Product',
        titleAr: 'منتج جديد',
        descriptionEn: 'Product description',
        descriptionAr: 'وصف المنتج',
        price: 99.99,
        compareAtPrice: 129.99,
        categoryId: 1,
        condition: ListingCondition.newItem,
        brand: 'BrandName',
        stockQuantity: 10,
        shippingAvailable: true,
        shippingCost: 5.99,
        location: 'Cairo',
        attributes: const {'Color': 'Red'},
        imagePaths: [photo.path],
      );

      final formData = interceptor.capturedFormData;
      expect(formData, isNotNull);
      final fields = {for (final f in formData!.fields) f.key: f.value};

      expect(fields['titleEn'], 'New Product');
      expect(fields['titleAr'], 'منتج جديد');
      expect(fields['price'], '99.99');
      expect(fields['compareAtPrice'], '129.99');
      expect(fields['categoryId'], '1');
      expect(fields['brand'], 'BrandName');
      expect(fields['stockQuantity'], '10');
      expect(fields['shippingAvailable'], 'true');
      expect(fields['shippingCost'], '5.99');
      expect(fields['location'], 'Cairo');
      expect(fields['condition'], '1');
      expect(fields['Attributes[0].Key'], 'Color');
      expect(fields['Attributes[0].Value'], 'Red');

      expect(formData.files, hasLength(1));
      expect(formData.files.single.key, 'imageFiles');
      expect(formData.files.single.value.filename, 'photo1.jpg');
    });

    test('omits attribute keys and imageFiles parts when none are given', () async {
      await datasource.createListing(
        titleEn: 'No Photo',
        titleAr: 'بدون صورة',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        price: 10,
        categoryId: 2,
        condition: ListingCondition.good,
        brand: '',
        stockQuantity: 1,
        shippingAvailable: false,
        shippingCost: 0,
        location: 'Giza',
        attributes: const {},
      );

      final formData = interceptor.capturedFormData;
      expect(formData, isNotNull);
      expect(formData!.files, isEmpty);
      expect(formData.fields.any((f) => f.key.startsWith('Attributes')), isFalse);
      expect(formData.fields.any((f) => f.key == 'brand'), isFalse);
    });

    test('multiple attributes get sequential indices', () async {
      await datasource.createListing(
        titleEn: 'Multi Attr',
        titleAr: 'خصائص متعددة',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        price: 10,
        categoryId: 2,
        condition: ListingCondition.good,
        brand: 'B',
        stockQuantity: 1,
        shippingAvailable: false,
        shippingCost: 0,
        location: 'Giza',
        attributes: const {'Color': 'Red', 'Size': 'L'},
      );

      final fields = {
        for (final f in interceptor.capturedFormData!.fields) f.key: f.value,
      };
      expect(fields['Attributes[0].Key'], 'Color');
      expect(fields['Attributes[0].Value'], 'Red');
      expect(fields['Attributes[1].Key'], 'Size');
      expect(fields['Attributes[1].Value'], 'L');
    });

    test('never sends more than 5 images even if given more', () async {
      final paths = [
        for (var i = 0; i < 8; i++)
          (File('${tmpDir.path}/photo$i.jpg')..writeAsBytesSync(const [0]))
              .path,
      ];

      await datasource.createListing(
        titleEn: 'Too Many Photos',
        titleAr: 'صور كثيرة',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        price: 10,
        categoryId: 2,
        condition: ListingCondition.good,
        brand: '',
        stockQuantity: 1,
        shippingAvailable: false,
        shippingCost: 0,
        location: 'Giza',
        attributes: const {},
        imagePaths: paths,
      );

      expect(interceptor.capturedFormData!.files, hasLength(5));
    });

    test('skips a stale local photo path instead of throwing', () async {
      final missingPath = '${tmpDir.path}/does_not_exist.jpg';

      await datasource.createListing(
        titleEn: 'Stale Draft',
        titleAr: 'مسودة قديمة',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        price: 10,
        categoryId: 2,
        condition: ListingCondition.good,
        brand: '',
        stockQuantity: 1,
        shippingAvailable: false,
        shippingCost: 0,
        location: 'Giza',
        attributes: const {},
        imagePaths: [missingPath],
      );

      expect(interceptor.capturedFormData!.files, isEmpty);
    });
  });
}
