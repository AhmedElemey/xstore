import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/firebase/fcm_token.dart';

void main() {
  group('waitForApnsToken', () {
    test('returns the first non-empty token without delaying', () async {
      var delays = 0;
      final token = await waitForApnsToken(
        getApnsToken: () async => 'apns-1',
        delay: (_) async {
          delays += 1;
        },
      );
      expect(token, 'apns-1');
      expect(delays, 0);
    });

    test('polls until a token appears', () async {
      var calls = 0;
      var delays = 0;
      final token = await waitForApnsToken(
        getApnsToken: () async {
          calls += 1;
          if (calls < 3) return null;
          return 'apns-late';
        },
        delay: (_) async {
          delays += 1;
        },
      );
      expect(token, 'apns-late');
      expect(calls, 3);
      expect(delays, 2);
    });

    test('returns null after maxAttempts and treats empty as missing', () async {
      var calls = 0;
      final token = await waitForApnsToken(
        getApnsToken: () async {
          calls += 1;
          return calls.isOdd ? null : '';
        },
        maxAttempts: 4,
        delay: (_) async {},
      );
      expect(token, isNull);
      expect(calls, 4);
    });
  });
}
