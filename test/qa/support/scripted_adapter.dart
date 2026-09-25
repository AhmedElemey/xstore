import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A reply the fake server sends back. [error] simulates a transport
/// failure (no response at all) instead of an HTTP status.
class FakeReply {
  const FakeReply(this.status, [this.body]) : error = null;
  const FakeReply.transport(DioExceptionType this.error)
      : status = 0,
        body = null;

  final int status;
  final Object? body;
  final DioExceptionType? error;
}

typedef FakeHandler = FutureOr<FakeReply> Function(RequestOptions req);

/// Routes `METHOD /path` (query string ignored) to a handler and records
/// every request so tests can assert on what actually hit the wire.
class ScriptedAdapter implements HttpClientAdapter {
  final Map<String, FakeHandler> _routes = {};
  final List<RequestOptions> requests = [];

  void on(String method, String path, FakeHandler handler) =>
      _routes['${method.toUpperCase()} $path'] = handler;

  void reply(String method, String path, int status, [Object? body]) =>
      on(method, path, (_) async => FakeReply(status, body));

  int count(String method, String path) => requests
      .where((r) => r.method == method.toUpperCase() && r.uri.path == path)
      .length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final key = '${options.method.toUpperCase()} ${options.uri.path}';
    final handler = _routes[key];
    if (handler == null) {
      return ResponseBody.fromString('', 404);
    }
    final reply = await handler(options);
    if (reply.error != null) {
      throw DioException(requestOptions: options, type: reply.error!);
    }
    final body = reply.body;
    return ResponseBody.fromString(
      body == null ? '' : (body is String ? body : jsonEncode(body)),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio scriptedDio(ScriptedAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://qa.test'))..httpClientAdapter = adapter;
