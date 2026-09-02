import '../router/app_routes.dart';

/// Hosts xStore Universal Links (iOS) / App Links (Android) are verified
/// for. Update here — and in the native manifests plus the backend
/// `.well-known` files — when the production domain is finalized. See
/// docs_business/launch_todos/07_deep_linking.md.
const supportedDeepLinkHosts = {'xstore.com', 'www.xstore.com'};

/// Resolves an incoming Universal/App Link URI to a go_router path, or null
/// if the link isn't one xStore recognizes.
///
/// Phase 1 only supports product links: `https://xstore.com/product/<id>`.
/// Unrecognized hosts/paths return null so the OS's own web fallback (or,
/// on Android, nothing) applies instead of navigating somewhere wrong.
String? routeFromDeepLinkUri(Uri uri) {
  if (!supportedDeepLinkHosts.contains(uri.host)) return null;

  final segments = uri.pathSegments;
  final isProductLink = segments.length == 2 &&
      segments[0] == 'product' &&
      segments[1].isNotEmpty;
  if (isProductLink) {
    return '${AppRoutes.product}/${segments[1]}';
  }

  return null;
}
