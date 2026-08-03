import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/firebase/fcm_message_route.dart';
import 'package:xstore/core/router/app_routes.dart';

void main() {
  group('routeFromRemoteMessageData', () {
    test('uses actionRoute when present', () {
      expect(
        routeFromRemoteMessageData({'actionRoute': '/notifications'}),
        AppRoutes.notifications,
      );
    });

    test('builds order path from orderId', () {
      expect(
        routeFromRemoteMessageData({'orderId': 'abc-123'}),
        '${AppRoutes.orderDetail}/abc-123',
      );
    });

    test('rejects external URLs', () {
      expect(
        routeFromRemoteMessageData({'actionRoute': 'https://evil.test'}),
        isNot('https://evil.test'),
      );
    });
  });

  group('routeFromRemoteMessage', () {
    test('falls back to inbox for notification-only payload', () {
      final message = RemoteMessage(
        notification: const RemoteNotification(title: 'Hi'),
      );
      expect(routeFromRemoteMessage(message), AppRoutes.notifications);
    });
  });
}
