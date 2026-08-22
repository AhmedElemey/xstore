/// Event and property names, aligned with the funnel schema in
/// `docs_business/launch_todos/03_funnel_metrics.md` (GA4-style snake_case).
/// Keep this the single source of truth — features must not hardcode event
/// or property name strings inline.
abstract final class AnalyticsEvents {
  // North-star funnel (view -> cart -> checkout -> purchase).
  static const String viewItem = 'view_item';
  static const String addToCart = 'add_to_cart';
  static const String beginCheckout = 'begin_checkout';
  static const String purchase = 'purchase';

  // Auth / retention.
  static const String loginSuccess = 'login_success';
  static const String registerSuccess = 'register_success';
  static const String logout = 'logout';
  static const String loginPromptShown = 'login_prompt_shown';

  // Discovery.
  static const String screenView = 'screen_view';
  static const String searchPerformed = 'search_performed';

  // Secondary engagement.
  static const String wishlistAdd = 'wishlist_add';
  static const String wishlistRemove = 'wishlist_remove';
  static const String checkoutPaymentMethodSelected =
      'checkout_payment_method_selected';
  static const String whatsappSellerTap = 'whatsapp_seller_tap';

  // Vendor funnel (listing live -> order fulfilled) — the other half of
  // the marketplace loop, see docs_business/launch_todos/03_funnel_metrics.md
  // Phase C.
  static const String listingPublished = 'listing_published';
  static const String listingStatusChanged = 'listing_status_changed';
  static const String listingResubmitted = 'listing_resubmitted';
  static const String listingDeleted = 'listing_deleted';
  static const String orderStatusChanged = 'order_status_changed';
}

abstract final class AnalyticsProps {
  static const String itemId = 'item_id';
  static const String category = 'category';
  static const String sellerId = 'seller_id';
  static const String priceEgp = 'price_egp';
  static const String guest = 'guest';
  static const String quantity = 'quantity';
  static const String cartValueEgp = 'cart_value_egp';
  static const String itemCount = 'item_count';
  static const String vendorCount = 'vendor_count';
  static const String orderId = 'order_id';
  static const String valueEgp = 'value_egp';
  static const String currency = 'currency';
  static const String paymentType = 'payment_type';
  static const String method = 'method';
  static const String source = 'source';
  static const String role = 'role';
  static const String query = 'query';
  static const String resultCount = 'result_count';
  static const String screenName = 'screen_name';
  static const String status = 'status';
  static const String reason = 'reason';
}
