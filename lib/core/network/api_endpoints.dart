import 'package:flutter/foundation.dart';

/// API route fragments; [baseUrl] comes from `--dart-define=API_BASE_URL=...`.
abstract final class ApiEndpoints {
  static const String _fromDefine = String.fromEnvironment('API_BASE_URL');

  /// Non-empty API origin (no trailing slash), e.g. `https://api.myapp.com`.
  ///
  /// **Release:** [API_BASE_URL] must be provided or the build fails (see static
  /// assert below). **Debug/profile:** falls back to the hosted integration
  /// backend when unset, so `flutter run --dart-define=MOCK=false` works with
  /// no further setup.
  static String get baseUrl {
    assert(
      !kReleaseMode || _fromDefine.trim().isNotEmpty,
      'Release builds require --dart-define=API_BASE_URL=<https://your-api-host> '
      '(non-empty). See README.md.',
    );
    final v = _fromDefine.trim();
    if (v.isNotEmpty) return v;
    assert(
      !kReleaseMode,
      'API_BASE_URL resolved empty in release; use --dart-define=API_BASE_URL=...',
    );
    return 'https://xstoreegy-001-site1.jtempurl.com';
  }

  // ---------------------------------------------------------------------
  // Legacy routes NOT in the confirmed backend contract (the
  // xStoreEcommerce Postman collection). Each remaining constant here has
  // live call sites that have no /api equivalent yet; they fail against
  // the real backend and are kept only until the backend adds routes.
  // ---------------------------------------------------------------------

  /// Legacy generic register — UI now uses [consumerRegister] /
  /// [vendorRegister]; only the unused RegisterUseCase path references it.
  static const String register = '/auth/register';

  // TODO(backend): no social/phone token-exchange routes exist yet.
  // socialLogin matches the spec handed to backend: POST /api/auth/social.
  static const String socialLogin = '$_api/auth/social';
  static const String phoneLogin = '/auth/phone';

  /// Legacy orders module — not on the confirmed `/api` contract; the hosted
  /// integration backend does not expose these routes yet (404). Call sites
  /// in `orders_remote_datasource.dart` treat 404 as an empty list until the
  /// backend ships.
  static const String orders = '/orders';
  static String ordersConsumer(String consumerId) =>
      '$orders/consumer/$consumerId';
  static String ordersVendor(String vendorId) => '$orders/vendor/$vendorId';
  static String ordersCourier(String courierId) =>
      '$orders/courier/$courierId';
  static String ordersVendorStats(String vendorId) =>
      '$orders/vendor/$vendorId/stats';
  static String orderById(String orderId) => '$orders/$orderId';
  static String orderCancel(String orderId) => '$orders/$orderId/cancel';
  static String orderConfirm(String orderId) => '$orders/$orderId/confirm';
  static String orderReject(String orderId) => '$orders/$orderId/reject';
  static String orderProcessing(String orderId) => '$orders/$orderId/processing';
  static String orderShipped(String orderId) => '$orders/$orderId/shipped';
  static String orderDelivered(String orderId) => '$orders/$orderId/delivered';

  /// Legacy store-hours module — not on the confirmed `/api` contract; hosted
  /// backend returns 404 until deployed. See `store_hours_datasource.dart`.
  static String vendorStoreHours(String vendorId) =>
      '/vendors/$vendorId/store-hours';
  static String vendorStoreStatus(String vendorId) =>
      '/vendors/$vendorId/store-status';

  /// Used by profile for vendor store head/stats, avatar upload, account
  /// delete and public store listings — none of which exist in the
  /// confirmed contract yet.
  static const String users = '/users';


  // ---------------------------------------------------------------------
  // Confirmed backend (xStoreEcommerce API, /api prefix).
  // ---------------------------------------------------------------------
  static const String _api = '/api';

  // Auth
  static const String consumerRegister = '$_api/auth/consumer/register';
  static const String vendorRegister = '$_api/auth/vendor/register';
  static const String apiLogin = '$_api/auth/login';
  static const String refreshToken = '$_api/auth/refresh-token';
  static const String changePassword = '$_api/auth/change-password';
  static const String apiLogout = '$_api/auth/logout';
  static const String forgotPassword = '$_api/auth/forgot-password';
  static const String verifyForgotPasswordOtp =
      '$_api/auth/verify-forget-password-otp';
  static const String getProfile = '$_api/auth/get-profile';
  static const String updateProfile = '$_api/auth/update-profile';
  static const String sendEmailOtp = '$_api/auth/send-email-otp';
  static const String sendPhoneOtp = '$_api/auth/send-phone-otp';
  static const String verifyEmail = '$_api/auth/verify-email';
  static const String verifyPhone = '$_api/auth/verify-phone';

  // Reference data (GET only — write ops are admin-only, not used by this app)
  static const String cities = '$_api/cities';
  static const String governments = '$_api/governments';
  static const String storeCategories = '$_api/storecategories';
  static const String catalogCategories = '$_api/categories';

  // Wishlist (all authenticated / user-scoped)
  static const String wishlist = '$_api/wishlist';
  static String wishlistItems(String consumerId) =>
      '$wishlist/$consumerId/items';
  static String wishlistItem(String consumerId, String listingId) =>
      '$wishlist/$consumerId/items/$listingId';

  // Notifications (all authenticated)
  static const String notifications = '$_api/notifications';
  static const String notificationsUnreadCount = '$notifications/unread-count';
  static const String notificationsReadAll = '$notifications/read-all';
  static String notificationMarkRead(String id) => '$notifications/$id/read';
  static String notificationMarkUnread(String id) =>
      '$notifications/$id/unread';
  static String notificationById(String id) => '$notifications/$id';

  // Reviews (nested under listings, /api-prefixed)
  static String apiListingReviews(String listingId) =>
      '$apiListings/$listingId/reviews';
  static String apiListingReview(String listingId, String reviewId) =>
      '$apiListings/$listingId/reviews/$reviewId';

  // Listings (new /api-prefixed contract). Legacy listings/myListings/
  // listingDetail/listingsSimilar above stay untouched.
  static const String apiListings = '$_api/listings';
  static const String apiMyListings = '$apiListings/my-listings';
  static String apiListingDetail(String id) => '$apiListings/$id';
  static String apiListingSimilar(String id, {int count = 6}) =>
      '$apiListings/$id/similar?count=$count';
}
