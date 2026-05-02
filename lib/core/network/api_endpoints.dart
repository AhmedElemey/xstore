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
}
