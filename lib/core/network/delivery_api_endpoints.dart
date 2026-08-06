/// Route fragments for the standalone delivery-backend service (a separate
/// .NET API from the main marketplace backend — see [ApiEndpoints]). Powers
/// the consumer/vendor package-delivery requests (Flow B); marketplace
/// orders (Flow A) still run on their existing mock path — see
/// `orders_remote_datasource.dart`.
abstract final class DeliveryApiEndpoints {
  static const String _fromDefine =
      String.fromEnvironment('DELIVERY_API_BASE_URL');

  /// Non-empty API origin (no trailing slash). This service isn't deployed
  /// anywhere yet (see delivery-backend's own README), so — unlike
  /// [ApiEndpoints.baseUrl] — there is no release assertion here; it just
  /// falls back to local dev (`dotnet run` default port).
  static String get baseUrl {
    final v = _fromDefine.trim();
    if (v.isNotEmpty) return v;
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
