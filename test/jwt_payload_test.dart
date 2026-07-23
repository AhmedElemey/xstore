import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/utils/jwt_payload.dart';

void main() {
  group('userIdFromJwt', () {
    test('reads sub claim from JWT payload', () {
      final payload = base64Url.encode(utf8.encode('{"sub":"42","email":"a@b.c"}'));
      final token = 'header.$payload.signature';
      expect(userIdFromJwt(token), '42');
    });

    test('reads nameid claim when sub is absent', () {
      final payload =
          base64Url.encode(utf8.encode('{"nameid":"vendor-7"}'));
      final token = 'header.$payload.signature';
      expect(userIdFromJwt(token), 'vendor-7');
    });

    test('returns null for invalid token', () {
      expect(userIdFromJwt(null), isNull);
      expect(userIdFromJwt(''), isNull);
      expect(userIdFromJwt('not-a-jwt'), isNull);
    });
  });
}
