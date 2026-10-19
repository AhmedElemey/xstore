import '../router/app_routes.dart';

/// Hosts xStore Universal Links (iOS) / App Links (Android) are verified
/// for. Update here — and in the native manifests plus the backend
/// `.well-known` files — when the production domain is finalized. See
/// docs_business/launch_todos/07_deep_linking.md.
const supportedDeepLinkHosts = {'xstore.com', 'www.xstore.com'};

/// Resolves an incoming Universal/App Link URI to a go_router path, or null
/// if the link isn't one xStore recognizes.
///
/// Supports product, seller/store, category, and order-status links (see
/// docs_business/launch_todos/07_deep_linking.md). Unrecognized hosts/paths
/// return null so the OS's own web fallback (or, on Android, nothing)
/// applies instead of navigating somewhere wrong.
///
/// Product/seller/category links are guest-accessible and navigate
/// immediately; order links are account-bound and are staged behind login
/// by the caller (see `deep_link_handling_provider.dart`).
String? routeFromDeepLinkUri(Uri uri) {
  if (!supportedDeepLinkHosts.contains(uri.host)) return null;

  final segments = uri.pathSegments;
  if (segments.length != 2 || segments[1].isEmpty) return null;

  final id = segments[1];
  switch (segments[0]) {
    case 'product':
      return '${AppRoutes.product}/$id';
    case 'seller':
      return AppRoutes.sellerPath(id);
    case 'order':
      return AppRoutes.orderPath(id);
    case 'category':
      return '${AppRoutes.explore}?category=${Uri.encodeComponent(id)}';
    default:
      return null;
  }
}
