/// All route paths for [GoRouter]. Use with `context.go` / `context.push`.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const socialRoleSelect = '/social-role-select';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const otp = '/otp';
  static const home = '/home';
  static const explore = '/explore';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const wishlist = '/wishlist';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const orders = '/orders';
  static const vendorOrders = '/vendor-orders';
  /// Vendor stack route (same [OrdersScreen] as consumer tab).
  static const incomingOrders = '/incoming-orders';
  static const orderDetail = '/order';
  static String orderPath(String orderId) => '$orderDetail/$orderId';
  static const settings = '/settings';
  static const analytics = '/analytics';
  static const myOrdersPlaceholder = '/my-orders-placeholder';
  static const earnings = '/earnings';
  static const recentlyViewed = '/recently-viewed';
  static const myReviews = '/my-reviews';
  static const changePassword = '/change-password';
  /// Inbox / activity feed.
  static const notifications = '/notifications';
  /// Push & email preference toggles.
  static const notificationSettings = '/notification-settings';
  static const paymentMethods = '/payment-methods';
  static const addresses = '/addresses';
  static const help = '/help';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const product = '/product';
  static const sellerProfile = '/seller';
  static const storeHours = '/store-hours';
  static const listingAdd = '/listing/add';
  static const listingMy = '/listing/my';
  /// Courier shell tabs ("Delivered by xStore" pilot).
  static const deliveries = '/deliveries';
  static const courierCash = '/courier-cash';

  static String chatThread(String threadId) => '/chat/$threadId';
}

/// Vendor-only areas: listing management, incoming orders, store tooling.
/// Guarded centrally in `computeXStoreAuthRedirect` — consumers who deep-link
/// or navigate here are sent back to home.
bool isVendorRestrictedRoute(String location) {
  return location.startsWith('/listing') ||
      location.startsWith(AppRoutes.vendorOrders) ||
      location == AppRoutes.incomingOrders ||
      location == AppRoutes.storeHours ||
      location == AppRoutes.earnings ||
      location == AppRoutes.analytics;
}

/// Consumer-only areas: the buying flow. Vendors don't shop in this app
/// (their shell has no cart/wishlist/orders tabs), so a vendor landing here
/// via deep link or stale navigation is sent back to home.
///
/// `/order/:id` is deliberately NOT here — vendors open it too, via
/// `/incoming-orders` → [OrdersScreen] → `OrderCard`.
bool isConsumerRestrictedRoute(String location) {
  return location == AppRoutes.cart ||
      location == AppRoutes.checkout ||
      location == AppRoutes.wishlist ||
      location == AppRoutes.orders;
}

/// Courier-only areas: the delivery run and collected-cash wallet.
/// Guarded centrally in `computeXStoreAuthRedirect`.
bool isCourierRestrictedRoute(String location) {
  return location.startsWith(AppRoutes.deliveries) ||
      location == AppRoutes.courierCash;
}

/// Browse-only areas open to guests (no account needed to look around the
/// marketplace). Everything account-bound — cart, wishlist, orders, profile,
/// vendor tooling — stays behind login; guests who navigate there are sent
/// to the login screen by `computeXStoreAuthRedirect`.
bool isGuestAccessibleRoute(String location) {
  return location == AppRoutes.home ||
      location == AppRoutes.explore ||
      location.startsWith('${AppRoutes.product}/') ||
      location.startsWith('${AppRoutes.sellerProfile}/') ||
      location == AppRoutes.help ||
      location == AppRoutes.terms ||
      location == AppRoutes.privacy;
}
