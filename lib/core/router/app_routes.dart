/// All route paths for [GoRouter]. Use with `context.go` / `context.push`.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const socialRoleSelect = '/social-role-select';
  static const forgotPassword = '/forgot-password';
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
  static const listingAdd = '/listing/add';
  static const listingMy = '/listing/my';

  static String chatThread(String threadId) => '/chat/$threadId';
}

/// Vendor-only areas (Add / My listings).
bool isVendorRestrictedRoute(String location) {
  return location.startsWith('/listing') || location.startsWith('/vendor-orders');
}
