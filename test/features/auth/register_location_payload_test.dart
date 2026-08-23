import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xstore/features/auth/domain/entities/consumer_register_params.dart';
import 'package:xstore/features/auth/domain/entities/vendor_register_params.dart';

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
          'token': 'test-token',
          'refreshToken': 'test-refresh',
        },
      ),
    );
  }
}

void main() {
  late Dio dio;
  late _CapturingInterceptor interceptor;
  late AuthRemoteDataSourceImpl datasource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    interceptor = _CapturingInterceptor();
    dio.interceptors.add(interceptor);
    datasource = AuthRemoteDataSourceImpl(dio);
  });

  test('consumer register sends cityId and governmentId from the pickers',
      () async {
    await datasource.registerConsumer(
      const ConsumerRegisterParams(
        fullNameEn: 'Jane Doe',
        fullNameAr: 'جين دو',
        email: 'jane@test.com',
        phoneNumber: '01012345678',
        password: 'Password1!',
        confirmPassword: 'Password1!',
        cityId: 1,
        governmentId: 16,
      ),
    );

    final body = interceptor.captured!.data as Map<String, dynamic>;
    expect(interceptor.captured!.path, '/api/auth/consumer/register');
    expect(body['cityId'], 1);
    expect(body['governmentId'], 16);
    expect(body['governorateId'], 16);
  });

  test('vendor register sends cityId and governmentId too', () async {
    final tmp = await Directory.systemTemp.createTemp('vendor_reg_test');
    addTearDown(() => tmp.delete(recursive: true));
    final photo = File('${tmp.path}/store.jpg')
      ..writeAsBytesSync(const [0, 1, 2, 3]);

    await datasource.registerVendor(
      VendorRegisterParams(
        fullNameEn: 'Ahmed Ali',
        fullNameAr: 'أحمد علي',
        email: 'ahmed@test.com',
        phoneNumber: '01112345678',
        password: 'Password1!',
        confirmPassword: 'Password1!',
        storeNameEn: 'Tech Store',
        storeNameAr: 'متجر التقنية',
        storeDescriptionEn: 'Best electronics',
        storeDescriptionAr: 'أفضل إلكترونيات',
        storeCategoryId: 1,
        storeCityId: 1,
        storeGovernmentId: 16,
        whatsappNumber: '01098765432',
        profileImagePath: photo.path,
      ),
    );

    final formData = interceptor.captured!.data as FormData;
    String field(String key) =>
        formData.fields.firstWhere((e) => e.key == key).value;

    expect(interceptor.captured!.path, '/api/auth/vendor/register');
    expect(field('storeCityId'), '1');
    expect(field('storeGovernorateId'), '16');
    expect(field('cityId'), '1');
    expect(field('governmentId'), '16');
  });
}
