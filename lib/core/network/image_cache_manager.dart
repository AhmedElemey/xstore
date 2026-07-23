import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'api_auth_headers.dart';

/// HTTP headers for loading backend-hosted images. The same Basic license
/// key used on API requests ([ApiAuthHeaders.basicLicenseKey]) is required
/// when fetching stored photos/avatars/banners.
abstract final class AppNetworkImageHeaders {
  static Map<String, String> get httpHeaders => const {
        'Authorization': ApiAuthHeaders.basicLicenseKey,
      };
}

/// Injects [AppNetworkImageHeaders] on every cache fetch so callers do not
/// need to repeat the header map when they only pass [cacheManager].
class _AuthHttpFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) {
    return super.get(
      url,
      headers: {...AppNetworkImageHeaders.httpHeaders, ...?headers},
    );
  }
}

class AppImageCacheManager {
  AppImageCacheManager._();

  static const _cacheKey = 'xstoreImageCache';

  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      fileService: _AuthHttpFileService(),
    ),
  );
}
