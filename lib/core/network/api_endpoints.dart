import 'package:flutter/foundation.dart';

/// API route fragments; [baseUrl] comes from `--dart-define=API_BASE_URL=...`.
abstract final class ApiEndpoints {
  static const String _fromDefine = String.fromEnvironment('API_BASE_URL');

  /// Non-empty API origin (no trailing slash), e.g. `https://api.myapp.com`.
  ///
  /// **Release:** [API_BASE_URL] must be provided or the build fails (see static
  /// assert below). **Debug/profile:** falls back to `http://localhost:8080` when
  /// unset so local development keeps working.
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
    return 'http://localhost:8080';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // TODO(backend): confirm route names and request/response payload shape.
  static const String socialLogin = '/auth/social';
  static const String phoneLogin = '/auth/phone';

  static const String banners = '/home/banners';
  static const String hotDeals = '/home/hot-deals';
  static const String categories = '/home/categories';

  static const String listings = '/listings';
  static const String myListings = '/listings/mine';
  static const String listingSearchSuggestions =
      '$listings/suggestions'; // GET ?q=

  /// Similar listings for product detail carousel.
  static String listingsSimilar({required String category}) =>
      '$listings/similar?category=${Uri.encodeQueryComponent(category)}';

  /// Product reviews for a listing.
  static String listingReviews(String listingId) =>
      '$listings/$listingId/reviews';

  /// Full product payload (listing + seller + specs + embedded reviews/summary).
  static String listingDetail(String id) => '$listings/$id';

  static const String users = '/users';

  // ---------------------------------------------------------------------
  // New backend (xStoreEcommerce API, /api prefix). Legacy constants above
  // are left untouched; they can be deleted once nothing references them.
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
