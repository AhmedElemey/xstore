import 'package:flutter/foundation.dart';

/// Route fragments for the standalone delivery-backend service (a separate
/// .NET API from the main marketplace backend — see [ApiEndpoints]). Powers
/// the consumer/vendor package-delivery requests (Flow B); marketplace
/// orders (Flow A) still run on their existing mock path — see
/// `orders_remote_datasource.dart`.
abstract final class DeliveryApiEndpoints {
  static const String _fromDefine =
      String.fromEnvironment('DELIVERY_API_BASE_URL');

  /// Non-empty API origin (no trailing slash). Debug/profile may fall back
  /// to local `dotnet run` (`localhost:5080`). Release must pass
  /// `--dart-define=DELIVERY_API_BASE_URL=https://…` — never localhost.
  static String get baseUrl {
    final v = _fromDefine.trim();
    if (v.isNotEmpty) return v;
    if (kReleaseMode) {
      throw StateError(
        'Release builds require --dart-define=DELIVERY_API_BASE_URL='
        '<https://your-delivery-api-host> (non-empty). See README.md.',
      );
    }
    return 'http://localhost:5080';
  }

  static const String login = '/api/auth/login';

  static const String deliveryRequests = '/api/delivery-requests';
  static String get deliveryRequestsMine => '$deliveryRequests/mine';
  static String deliveryRequestConfirm(String id) =>
      '$deliveryRequests/$id/confirm';
  static String deliveryRequestCancel(String id) =>
      '$deliveryRequests/$id/cancel';
  static String get deliveryRequestsCourierMine =>
      '$deliveryRequests/courier/mine';
  static String deliveryRequestPickup(String id) =>
      '$deliveryRequests/$id/pickup';
  static String deliveryRequestDeliver(String id) =>
      '$deliveryRequests/$id/deliver';
}
