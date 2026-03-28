/// All route paths for [GoRouter]. Use with `context.go` / `context.push`.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const explore = '/explore';
  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const profile = '/profile';
  static const orders = '/orders';
  static const product = '/product';
  static const sellerProfile = '/seller';
  static const listingAdd = '/listing/add';
  static const listingMy = '/listing/my';
}

/// Vendor-only areas (Add / My listings).
bool isVendorRestrictedRoute(String location) {
  return location.startsWith('/listing');
}
