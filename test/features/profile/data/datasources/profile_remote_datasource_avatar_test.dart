import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist datasource tests.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    final result = _respond(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

DioException _badResponse(RequestOptions options, int statusCode) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: statusCode),
    );

Future<File> _tempJpeg() async {
  final tmp = await Directory.systemTemp.createTemp('avatar_ds_test');
  addTearDown(() => tmp.delete(recursive: true));
  return File('${tmp.path}/avatar.jpg')..writeAsBytesSync(const [0, 1, 2, 3]);
}

void main() {
  late Dio dio;
  late ProfileRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  group('updateAvatar', () {
    test(
      'POSTs multipart to /api/uploads/avatar with field `file` attached',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {'url': 'https://cdn.example.test/avatars/1.jpg'};
        });
        datasource = ProfileRemoteDataSourceImpl(dio);
        final photo = await _tempJpeg();

        final url = await datasource.updateAvatar(
          userId: 'user_1',
          filePath: photo.path,
        );

        expect(captured!.method, 'POST');
        expect(captured!.path, ApiEndpoints.apiUpload('avatar'));
        final formData = captured!.data as FormData;
        expect(formData.files, hasLength(1));
        expect(formData.files.single.key, 'file');
        expect(formData.files.single.value.filename, 'avatar.jpg');
        expect(url, 'https://cdn.example.test/avatars/1.jpg');
      },
    );

    test(
      'parses avatarUrl / imageUrl / nested user.avatarUrl the same way',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        final photo = await _tempJpeg();

        Future<String> parse(Object? body) async {
          dio = buildDio((_) => body);
          datasource = ProfileRemoteDataSourceImpl(dio);
          return datasource.updateAvatar(
            userId: 'user_1',
            filePath: photo.path,
          );
        }

        expect(
          await parse({'avatarUrl': 'https://cdn.example.test/a.jpg'}),
          'https://cdn.example.test/a.jpg',
        );
        expect(
          await parse({'imageUrl': 'https://cdn.example.test/b.jpg'}),
          'https://cdn.example.test/b.jpg',
        );
        expect(
          await parse({
            'user': {'avatarUrl': 'https://cdn.example.test/c.jpg'},
          }),
          'https://cdn.example.test/c.jpg',
        );
      },
    );

    test(
      'throws ServerException when the body has no URL',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((_) => <String, dynamic>{});
        datasource = ProfileRemoteDataSourceImpl(dio);
        final photo = await _tempJpeg();

        expect(
          () => datasource.updateAvatar(
            userId: 'user_1',
            filePath: photo.path,
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Avatar upload returned no URL.',
            ),
          ),
        );
      },
    );

    test(
      'throws ServerException on a null response body',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((_) => null);
        datasource = ProfileRemoteDataSourceImpl(dio);
        final photo = await _tempJpeg();

        expect(
          () => datasource.updateAvatar(
            userId: 'user_1',
            filePath: photo.path,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test(
      'maps a 500 response to a ServerException',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((options) => _badResponse(options, 500));
        datasource = ProfileRemoteDataSourceImpl(dio);
        final photo = await _tempJpeg();

        expect(
          () => datasource.updateAvatar(
            userId: 'user_1',
            filePath: photo.path,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
