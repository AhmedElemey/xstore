/// Centralized copy. Prefer these over literals in UI.
abstract final class AppStrings {
  // App
  static const appName = 'xStore';
  static const tagline = 'Buy & Sell Anything';

  // Auth
  static const login = 'Login';
  static const register = 'Register';
  static const logout = 'Sign Out';
  static const email = 'Email';
  static const password = 'Password';
  static const createAccount = 'Create account';
  static const signInPrompt = 'Sign in to continue';

  // Home
  static const searchHint = 'Search products...';
  static const hotDeals = '🔥 Hot Deals';
  static const newArrivals = '✨ New Arrivals';
  static const flashSale = '⚡ Flash Sale';
  static const flashSaleBannerBody = 'Flash sale — limited time offers inside';
  static const shopByCategory = 'Shop by Category';
  static const recommended = '👤 Recommended for You';
  static const recommendedSubtitle = 'Based on your browsing';
  static const seeAll = 'See All';
  static const seeAllReviews = 'See All Reviews';
  static const freeShippingBadge = '🚚 Free Shipping';
  static const securePayBadge = '🔒 Secure Pay';
  static const easyReturnsBadge = '↩️ Easy Returns';
  static const shopNow = 'Shop Now';
  static const mensFashion = "Men's Fashion";
  static const womensFashion = "Women's Fashion";
  static const categoryQueryMens = 'mens_fashion';
  static const categoryQueryWomens = 'womens_fashion';
  static const notifications = 'Notifications';
  static const notificationsMarkAllRead = 'Mark all read';
  static const notificationsNoMore = 'No more notifications';
  static String notificationsUnreadBannerLine(int n) =>
      '🔔 You have $n unread notifications';
  static const notificationsEmptyAllTitle = "You're all caught up! 🎉";
  static const notificationsEmptyAllSubtitle =
      "No notifications yet. We'll notify you about orders, deals, and important updates.";
  static String notificationsEmptyFilterTitle(String filter) =>
      'No $filter notifications';
  static String notificationsEmptyFilterSubtitle(String scope) =>
      'Your $scope notifications will appear here';
  static const notificationsShowAll = 'Show All';
  static const notificationsFilterAll = 'All';
  static const notificationsFilterOrders = 'Orders';
  static const notificationsFilterDeals = 'Deals';
  static const notificationsFilterListings = 'Listings';
  static const notificationsFilterMessages = 'Messages';
  static const notificationsFilterSystem = 'System';
  static const notificationsSwipeDelete = 'Delete';
  static const notificationsSwipeMarkRead = 'Mark Read';
  static const notificationsMenuMarkRead = 'Mark as Read';
  static const notificationsMenuMarkUnread = 'Mark as Unread';
  static const notificationsMenuDelete = 'Delete';
  static const notificationsMenuCopy = 'Copy text';
  static const notificationsCopied = 'Copied to clipboard';
  static const notificationsUndo = 'Undo';
  static String notificationsDeletedSnack(String title) =>
      '"$title" removed';
  static const notificationsGroupToday = 'TODAY';
  static const notificationsGroupYesterday = 'YESTERDAY';
  static const notificationsGroupThisWeek = 'THIS WEEK';
  static const notificationsGroupEarlier = 'EARLIER';
  static const notificationsTimeJustNow = 'Just now';
  static String notificationsTimeMinutesAgo(int m) => '${m}m ago';
  static String notificationsTimeHoursAgo(int h) => '${h}h ago';
  static const notificationsTimeYesterday = 'Yesterday';
  static const notificationSettingsTitle = 'Notification settings';
  static const notificationSettingsSave = 'Save Preferences';
  static const notificationSettingsSaved = 'Preferences saved';
  static const notificationSettingsSectionOrders = 'Order updates';
  static const notificationSettingsSectionDeals = 'Deals & offers';
  static const notificationSettingsSectionStore = 'Store updates';
  static const notificationSettingsSectionMessages = 'Messages';
  static const notificationSettingsSectionDelivery = 'Delivery';
  static const notificationSettingsOrderConfirmed = 'Order confirmed';
  static const notificationSettingsOrderShipped = 'Order shipped';
  static const notificationSettingsOrderDelivered = 'Order delivered';
  static const notificationSettingsOrderCancelled = 'Order cancelled';
  static const notificationSettingsFlashSales = 'Flash sales';
  static const notificationSettingsPriceDrops = 'Price drops';
  static const notificationSettingsBackInStock = 'Back in stock';
  static const notificationSettingsPromotional = 'Promotional offers';
  static const notificationSettingsNewOrders = 'New orders';
  static const notificationSettingsListingApproved = 'Listing approved';
  static const notificationSettingsListingRejected = 'Listing rejected';
  static const notificationSettingsLowStock = 'Low stock alerts';
  static const notificationSettingsPaymentReceived = 'Payment received';
  static const notificationSettingsNewMessages = 'New messages';
  static const notificationSettingsPush = 'Push notifications';
  static const notificationSettingsEmail = 'Email notifications';
  static const notificationSettingsSms = 'SMS notifications';

  // Listing
  static const addListing = 'Add Listing';
  static const myListings = 'My Listings';
  static const publishListing = '🚀 Publish Listing';
  static const saveDraft = 'Save Draft';
  static const newListing = 'New Listing';

  // Profile
  static const vendorAccount = 'Vendor Account';
  static const customerAccount = 'Customer account';
  static const theme = 'Theme';
  static const themeSystem = 'System';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const darkMode = 'Dark Mode';
  static const lightMode = 'Light Mode';

  // Profile (screens & menus)
  static const editProfile = 'Edit Profile';
  static const save = 'Save';
  static const saveChanges = 'Save Changes';
  static const settings = 'Settings';
  static const sectionMyActivity = 'MY ACTIVITY';
  static const sectionAccountSettings = 'ACCOUNT SETTINGS';
  static const sectionPreferences = 'PREFERENCES';
  static const sectionSupport = 'SUPPORT';
  static const sectionDangerZone = 'DANGER ZONE';
  static const menuMyListings = 'My Listings';
  static const menuMyOrders = 'My Orders';
  static const menuAnalytics = 'Analytics';
  static const menuEarnings = 'Earnings';
  static const menuWishlist = 'Wishlist';
  static const menuRecentlyViewed = 'Recently Viewed';
  static const menuMyReviews = 'My Reviews';
  static const menuPersonalInfo = 'Personal Info';
  static const socialLinks = 'Social links';
  static const menuChangePassword = 'Change Password';
  static const menuNotificationsSettings = 'Notifications';
  static const menuLanguage = 'Language';
  static const menuPaymentMethods = 'Payment Methods';
  static const menuAddresses = 'My Addresses';
  static const menuDarkMode = 'Dark Mode';
  static const menuPushNotifications = 'Push Notifications';
  static const menuEmailUpdates = 'Email Updates';
  static const menuHelpCenter = 'Help Center';
  static const menuTerms = 'Terms of Service';
  static const menuPrivacy = 'Privacy Policy';
  static const menuRateApp = 'Rate xStore';
  static const menuShareApp = 'Share xStore';
  static const manageStore = 'Manage Store';
  static const statSales = 'Sales';
  static const statSalesShort = 'sales';
  static const statRating = 'Rating';
  static const statResponse = 'Response';
  static const statOrders = 'Orders';
  static const statWishlist = 'Wishlist';
  static const statDzdSaved = 'DZD Saved';
  static const currencyDzd = 'DZD';
  static const storeInformation = 'Store Information';
  static const fullNameLabel = 'Full Name';
  static const emailAddressLabel = 'Email Address';
  static const phoneNumberLabel = 'Phone Number';
  static const dateOfBirthLabel = 'Date of Birth';
  static const locationCityLabel = 'Location / City';
  static const bioLabel = 'Bio / About';
  static const bioHint = 'Tell buyers a bit about yourself';
  static const storeNameLabel = 'Store Name';
  static const storeCategoryLabel = 'Store Category';
  static const storeDescriptionLabel = 'Store Description';
  static const storeCityLabel = 'Store City';
  static const storeWilayaLabel = 'Store Wilaya';
  static const whatsappLabel = 'WhatsApp Number';
  static const instagramLabel = 'Instagram handle';
  static const facebookLabel = 'Facebook page';
  static const logoutConfirmTitle = 'Log out of xStore?';
  static const logoutConfirmSubtitle =
      "You'll need to login again to access your account";
  static const cancel = 'Cancel';
  static const logOut = 'Log Out';
  static const deleteAccount = 'Delete Account';
  static const deleteAccountDialogTitle = 'Delete account permanently';
  static const deleteAccountPermanentWarning = 'This action is permanent';
  static const deleteAccountTypeHint = 'Type DELETE to confirm';
  static const deleteMyAccount = 'Delete My Account';
  static const deleteConfirmKeyword = 'DELETE';
  static const choosePhotoSource = 'Profile photo';
  static const takePhoto = 'Camera';
  static const chooseFromGallery = 'Gallery';
  static const removePhoto = 'Remove Photo';
  static const profileUpdatedSuccess = 'Profile updated';
  static const languageTitle = 'Language';
  static const languageEnglish = 'English';
  static const languageFrench = 'French';
  static const languageArabic = 'Arabic';
  static const profileFooterLine = 'xStore v1.0.0 · Made with ❤️ in Algeria';
  static const statStoreViews = 'Views';
  static const statStoreSaves = 'Saves';
  static const statStoreActive = 'Active';
  static const storeMetaLinePrefix = 'Since ';
  /// Buyer-facing vendor store header (profile card still uses [storeMetaLinePrefix]).
  static const storeJoinedPrefix = 'Joined ';
  static const followStore = 'Follow Store';
  static const share = 'Share';
  static const storeDescriptionHeading = 'About the store';
  static const allCategoriesChip = 'All';
  static const vendorStoreStatListings = 'Active Listings';
  static const vendorStoreStatSales = 'Total Sales';
  static const vendorStoreStatResponse = 'Response Rate';
  static const placeholderScreenSubtitle = 'This screen is coming soon.';
  static const shareXStoreMessage =
      'Shop and sell on xStore — Algeria\'s modern marketplace.';
  /// Placeholder listing URLs for “Rate xStore”.
  static const iosAppStoreUrl = 'https://apps.apple.com';
  static const androidPlayStoreUrl = 'https://play.google.com/store';
  static const verified = 'Verified';
  static const requiredField = 'Required';

  /// Vendor store category picker (edit profile).
  static List<String> get storeCategoryPickerOptions => const [
        'Electronics',
        'Fashion',
        'Home',
        'Sports',
        'Beauty',
        'Other',
      ];

  // Nav
  static const navHome = 'Home';
  static const navExplore = 'Explore';
  static const navWishlist = 'Wishlist';
  static const navOrders = 'Orders';
  static const navProfile = 'Profile';
  static const navCart = 'Cart';
  static const navAddListing = 'Add Listing';

  // Explore
  static const exploreSearchPlaceholder = 'Search listings…';
  static const clearAllFilters = 'Clear All';
  static const filters = 'Filters';
  static const addFilters = '+ Filters';
  static const applyFilters = 'Apply Filters';
  static String applyFiltersCount(int n) => '$applyFilters ($n)';
  static const resetFilters = 'Reset';
  static const sortBy = 'Sort by';
  static const sortNewest = 'Newest';
  static const sortOldest = 'Oldest';
  static const sortPriceAsc = 'Price ↑';
  static const sortPriceDesc = 'Price ↓';
  static const sortMostViewed = 'Most Viewed';
  static const sortRelevance = 'Relevance';
  static const sortByRating = 'Rating';
  static const resultsFor = 'Results for';
  static const allListingsLabel = 'All listings';
  static const noResultsTitle = 'No listings found';
  static const noResultsSubtitle = 'Try different keywords or filters.';
  static const recentSearches = 'Recent searches';
  static const addToCart = 'Add to Cart';
  static const category = 'Category';
  static const condition = 'Condition';
  static const priceRange = 'Price range';
  static const minPriceLabel = 'Min';
  static const maxPriceLabel = 'Max';
  static const minRating = 'Minimum rating';
  static const location = 'Location';
  static const shippingOnly = 'Shipping available';
  static const gridView = 'Grid';
  static const listView = 'List';
  static const ratingStars4Plus = '⭐ 4+';
  static const ratingStars3Plus = '⭐ 3+';
  static const ratingStars2Plus = '⭐ 2+';
  static const starChar = '★';

  // Orders
  static const ordersEmptyTitle = 'No orders yet';
  static const ordersEmptySubtitle =
      'When you buy something, your orders will show up here.';
  static const ordersIncomingTitle = 'Incoming Orders';
  static const ordersMyTitle = 'My Orders';
  static const ordersSearchHint = 'Search order or product…';
  static const ordersFilterAll = 'All';
  static const ordersFilterPending = 'Pending';
  static const ordersFilterConfirmed = 'Confirmed';
  static const ordersFilterProcessing = 'Processing';
  static const ordersFilterShipped = 'Shipped';
  static const ordersFilterDelivered = 'Delivered';
  static const ordersFilterCancelled = 'Cancelled';
  static const ordersFilterRefunded = 'Refunded';
  static const ordersSortHighestValue = 'Highest Value';
  static const ordersSortNeedsAction = 'Needs Action';
  static const ordersCountLabel = 'orders';
  static String ordersCountLine(int n) => '$n $ordersCountLabel';
  static const ordersStatPendingLabel = 'Pending';
  static const ordersStatActiveLabelTitle = 'Active';
  static const ordersStatMonthLabel = 'Month';
  static const ordersStatTotalLabel = 'Total';
  static const ordersMoreItemsSuffix = 'more item';
  static const ordersMoreItemsSuffixPlural = 'more items';
  static String ordersMoreItems(int n) =>
      n == 1 ? '+ $n $ordersMoreItemsSuffix' : '+ $n $ordersMoreItemsSuffixPlural';
  static const ordersQtyTotalLinePrefix = 'Qty';
  static const ordersFromStorePrefix = 'From';
  static const ordersEstimatedDelivery = '🚚 Estimated';
  static const ordersPaymentLine = 'Payment';
  static const ordersTrackOrder = 'Track Order';
  static const ordersViewDetails = 'View Details';
  static const ordersCancelOrder = 'Cancel Order';
  static const ordersConfirmReceipt = '✓ Confirm Receipt';
  static const ordersLeaveReview = 'Leave Review';
  static const ordersReorder = 'Reorder';
  static const ordersRejectOrder = 'Reject';
  static const ordersConfirmOrderCta = '✓ Confirm Order';
  static const ordersMarkProcessing = 'Mark as Processing';
  static const ordersMarkShipped = 'Mark as Shipped';
  static const ordersViewTracking = 'View Tracking';
  static const ordersShopAgain = '🛒 Shop Again';
  static const ordersEmptyFilteredTitle = 'No matching orders';
  static const ordersEmptyConsumerSubtitle =
      'Start shopping to see your orders here';
  static const ordersBrowseProducts = 'Browse Products';
  static const ordersDetailTitlePrefix = 'Order #';
  static const ordersShareSummary = 'Share order';
  static const ordersSoldBy = 'Sold by';
  static const ordersBuyerInfo = 'Buyer Info';
  static const ordersMessageSeller = '💬 Message Seller';
  static const ordersMessageSellerSoon = 'Messaging — coming soon';
  static const ordersWhatsapp = '💬 WhatsApp';
  static const ordersDeliveryAddressTitle = 'Delivery Address';
  static const ordersItemsSectionTitle = 'Items Ordered';
  static String ordersItemsSectionCount(int n) => '$ordersItemsSectionTitle ($n)';
  static const ordersTrackingSectionTitle = 'Tracking Information';
  static const ordersPaymentSectionTitle = 'Payment Details';
  static const ordersNotesSectionTitle = 'Order Notes';
  static const ordersSubtotal = 'Subtotal';
  static const ordersShipping = 'Shipping';
  static const ordersDiscount = 'Discount';
  static const ordersTotal = 'Total';
  static const ordersPaidBadge = 'Paid';
  static const ordersPaymentPendingBadge = 'Pending';
  static const ordersViewProduct = 'View Product';
  static const ordersCopyTracking = 'Copy';
  static const ordersTrackingCopied = 'Copied to clipboard';
  static const ordersTrackOnCourier = 'Track on Courier Website';
  static const ordersCourierWebsiteSoon = 'Courier tracking — coming soon';
  static const ordersCurrentLocationMock = 'In transit — Algiers hub';
  static const ordersExpectedPrefix = '📅 Expected by';
  static const ordersAddTrackingTitle = 'Add Tracking Info';
  static const ordersTrackingNumberLabel = 'Tracking Number (optional)';
  static const ordersCourierNameLabel = 'Courier name (optional)';
  static const ordersEstimatedDeliveryLabel = 'Estimated delivery';
  static const ordersConfirmShipment = 'Confirm Shipment';
  static const ordersCancelDialogTitle = 'Cancel this order?';
  static const ordersCancelReasonLabel = 'Reason';
  static const ordersCancelReasonChangedMind = 'Changed my mind';
  static const ordersCancelReasonBetterPrice = 'Found better price';
  static const ordersCancelReasonMistake = 'Ordered by mistake';
  static const ordersCancelReasonOther = 'Other';
  static const ordersConfirmReceiptTitle = 'Confirm receipt?';
  static const ordersConfirmReceiptBody =
      'Confirm you received this order?';
  static const ordersConfirm = 'Confirm';
  static const ordersRejectDialogTitle = 'Reject order';
  static const ordersRejectReasonHint = 'Reason for rejection';
  static const ordersSubmitReview = 'Submit Review';
  static const ordersReviewHint = 'Tell others about your purchase';
  static const ordersReviewThanks = 'Thanks for your review!';
  static const ordersReviewSheetTitle = 'Leave a review';
  static const ordersPaymentCashOnDelivery = 'Cash on Delivery';
  static const ordersPaymentCib = 'CIB Card';
  static const ordersPaymentDahabi = 'Dahabi Card';
  static const ordersPaymentBaridimob = 'BaridiMob';
  static const ordersTimelinePlaced = 'Order Placed';
  static const ordersTimelineConfirmed = 'Confirmed';
  static const ordersTimelineProcessing = 'Processing';
  static const ordersTimelineShipped = 'Shipped';
  static const ordersTimelineDelivered = 'Delivered';
  static const ordersTimelineHeading = 'Order progress';
  static const ordersTimelinePending = 'Pending';
  static const ordersCancelReasonSection = 'Cancellation reason';
  static const statusSubtitlePending = 'Waiting for vendor confirmation';
  static const statusSubtitleConfirmed = 'Vendor confirmed your order';
  static const statusSubtitleProcessing = 'Seller is preparing your order';
  static const statusSubtitleShipped = 'Your order is on the way!';
  static const statusSubtitleDelivered = 'Order delivered successfully';
  static const statusSubtitleCancelled = 'This order was cancelled';
  static const statusSubtitleRefunded = 'Refund processed';
  static const ordersFiltersMoreSoon = 'More filters — coming soon';
  static const orderHashPrefix = 'Order #';
  static const vendorNeedsAttention = 'Needs attention';

  // Wishlist
  static const wishlistEmptyTitle = 'Your wishlist is empty';
  static const wishlistEmptySubtitle =
      'Save items you love by tapping the heart icon on any product';
  static const wishlistDiscoverProducts = 'Discover Products';
  static String wishlistAppBarTitle(int n) => 'My Wishlist ($n)';
  static const wishlistForBuyersTitle = 'Wishlist is for Buyers';
  static const wishlistForBuyersSubtitle =
      'Create a consumer account to save and track your favorite products';
  static const wishlistExploreAsBuyer = 'Explore as Buyer';
  static const wishlistSelect = 'Select';
  static const wishlistCancelSelect = 'Cancel';
  static String wishlistSelectedCount(int n) => '$n selected';
  static const wishlistSort = 'Sort';
  static const wishlistSortRecentlyAdded = 'Recently Added';
  static const wishlistSortPriceLow = 'Price: Low to High';
  static const wishlistSortPriceHigh = 'Price: High to Low';
  static const wishlistSortPriceDrop = 'Price Drop';
  static const wishlistSortBiggestDiscount = 'Biggest Discount';
  static const wishlistSortNameAz = 'Name A–Z';
  static const wishlistFilterAll = 'All';
  static const wishlistFilterAvailable = 'Available';
  static const wishlistFilterPriceDropped = 'Price Dropped';
  static const wishlistFilterInCart = 'In Cart';
  static String wishlistPriceDropBanner(int n) =>
      '🎉 Price drop on $n items in your wishlist!';
  static const wishlistPriceDropBannerSubtitle =
      'Prices dropped since you saved them';
  static const wishlistViewPriceDrops = 'View Price Drops';
  static const wishlistPriceDropBadge = 'Price Drop';
  static String wishlistPriceDropPercent(int p) => '↓ $p% Price Drop';
  static const wishlistOutOfStock = 'Out of Stock';
  static const wishlistInCartBadge = '✓ In Cart';
  static const wishlistRemove = '♡ Remove';
  static const wishlistAddToCart = '🛒 Add to Cart';
  static const wishlistInCartCta = '✓ In Cart';
  static const wishlistSwipeAddCart = 'Add to Cart';
  static const wishlistMoveAllToCart = 'Move All to Cart';
  static const wishlistShareWishlist = 'Share Wishlist';
  static String wishlistMoveAllSummary(int n) => '$n items added to cart';
  static const wishlistViewCart = 'View Cart';
  static String wishlistShareText(String link) =>
      'Check out my wishlist on xStore! 🛍️\n$link';
  static String wishlistItemsAvailableLine(int total, int avail) =>
      '$total items · $avail available';
  static const wishlistRemoveSelected = 'Remove Selected';
  static String wishlistAddToCartSelected(int n) => 'Add to Cart ($n)';
  static String wishlistRemoveSelectedCount(int n) => 'Remove Selected ($n)';
  static const wishlistSavedSnack = 'Saved to Wishlist ❤️';
  static const wishlistView = 'View';
  static const wishlistRemovedSnack = 'Removed from Wishlist';
  static String wishlistFilterEmptyTitle(String filterName) =>
      'No $filterName items';
  static const wishlistShowAllItems = 'Show All Items';
  static const wishlistReviewsWord = 'reviews';
  static const wishlistGridContentDesc = 'Grid view';
  static const wishlistListContentDesc = 'List view';
  static const wishlistNoAvailableItems = 'No available items';
  static const wishlistNoPriceDroppedItems = 'No price dropped items';
  static const wishlistNoInCartItems = 'No in cart items';
  static String wishlistAddedToCartCount(int n) => '$n items added to cart';
  static const wishlistSingleAddedToCart = 'Added to cart';
  static const wishlistSelectAll = 'Select All';
  static const wishlistDeselectAll = 'Deselect All';

  // Cart (consumer)
  static String cartAppBarTitle(int n) => 'My Cart ($n items)';
  static const cartForBuyersTitle = 'Cart is for Buyers';
  static const cartForBuyersSubtitle =
      'Switch to a consumer account to shop on xStore';
  static const cartExploreAsBuyer = 'Explore as Buyer';
  static const cartClearTitle = 'Clear your entire cart?';
  static String cartClearBody(int n) =>
      'This will remove all $n items from your cart.';
  static const cartClearConfirm = 'Clear Cart';
  static const cartSelectAll = 'Select All';
  static String cartSelectAllCount(int n) => 'Select All ($n items)';
  static const cartTotalLabel = 'Total';
  static const cartEmptyTitle = 'Your cart is empty';
  static const cartEmptySubtitle =
      "Looks like you haven't added anything to your cart yet";
  static const cartStartShopping = 'Start Shopping';
  static const cartOrWishlist = 'Or check your Wishlist';
  static const cartWishlistArrow = 'Wishlist →';
  static const cartRemove = '🗑 Remove';
  static const cartSaveForLater = '♡ Save for Later';
  static const cartUnavailableBadge = 'Unavailable';
  static const cartUnavailableHint =
      'This item is no longer available';
  static const cartSwipeRemove = 'Remove';
  static String cartRemovedSnack(String name) => '$name removed from cart';
  static const cartUndo = 'Undo';
  static const cartShippingFree = '🚚 Free Shipping';
  static String cartShippingPaid(double amount) =>
      '🚚 +${amount.round()} DZD shipping';
  static const cartPickupOnly = '🚫 Pickup Only';
  static const cartPromoHeading = '🏷️ Have a promo code?';
  static const cartCouponHint = 'Enter coupon code…';
  static const cartApply = 'Apply';
  static const cartCouponRemove = 'Remove';
  static String cartCouponApplied(String code, String detail) =>
      '✅ "$code" — $detail';
  static const cartCouponInvalid = 'Invalid coupon code';
  static const cartCouponMinOrder = 'Minimum order 5,000 DZD required';
  static const cartOrderSummary = 'Order Summary';
  static String cartSubtotalLine(int n) => 'Subtotal ($n items)';
  static const cartShippingLine = 'Shipping';
  static String cartCouponLine(String code) => 'Coupon ($code)';
  static const cartTotalLine = 'Total';
  static const cartCashOnDeliveryNote = '💳 Cash on Delivery available';
  static const cartSecureCheckout = '🔒 Secure checkout guaranteed';
  static const cartProceedCheckout = 'Proceed to Checkout';
  static String cartProceedCheckoutTotal(String total) =>
      'Proceed to Checkout ($total)';
  static String cartCheckoutItems(int n) => 'Checkout ($n items)';
  static const cartYouMayAlsoLike = 'You May Also Like';
  static const checkoutTitle = 'Checkout';
  static const checkoutContinue = 'Continue';
  static const checkoutStepAddress = 'Address';
  static const checkoutStepPayment = 'Payment';
  static const checkoutStepConfirm = 'Confirm';
  static const checkoutDeliveryTitle = 'Delivery Address';
  static const checkoutAddAddress = '+ Add New Address';
  static const checkoutSaveAddress = 'Save Address';
  static const checkoutFullName = 'Full Name';
  static const checkoutPhone = 'Phone';
  static const checkoutStreet = 'Street';
  static const checkoutCity = 'City';
  static const checkoutWilaya = 'Wilaya';
  static const checkoutPostalCode = 'Postal Code';
  static const checkoutSetDefault = 'Set as Default';
  static const checkoutEdit = 'Edit';
  static const checkoutPaymentTitle = 'Payment Method';
  static const checkoutPayCodTitle = '💵 Cash on Delivery';
  static const checkoutPayCodSubtitle = 'Pay when your order arrives';
  static const checkoutPayCibTitle = '💳 CIB Card';
  static const checkoutPayCibSubtitle = 'Debit/Credit card payment';
  static const checkoutPayDahabiTitle = '🟡 Dahabicard';
  static const checkoutPayDahabiSubtitle = 'Algeria Post golden card';
  static const checkoutPayBaridiTitle = '🟢 BaridiMob';
  static const checkoutPayBaridiSubtitle = 'Algeria Post mobile payment';
  static const checkoutCardExpiry = 'MM/YY';
  static const checkoutCardCvv = 'CVV';
  static const checkoutCardNumber = 'Card number';
  static const checkoutDeliveryNoteLabel = 'Delivery note (optional)';
  static const checkoutDeliveryNoteHint =
      'Add a note for your vendor (e.g. leave at door, call on arrival)';
  static const checkoutReviewTitle = 'Review Your Order';
  static String checkoutItemsFromSellers(int items, int sellers) =>
      '$items items from $sellers sellers';
  static const checkoutEstimatedDelivery = '🚚 Estimated: 3–5 business days';
  static const checkoutTermsBefore = 'By placing this order you agree to our';
  static const checkoutTermsAnd = 'and';
  static const checkoutReturnPolicy = 'Return Policy';
  static const checkoutPlaceOrder = '🛒 Place Order';
  static String checkoutPlaceOrderTotal(String total) =>
      '🛒 Place Order · $total';
  static const checkoutErrorNoAddress = 'Please select or add an address';
  static const checkoutErrorNoPayment = 'Please select a payment method';
  static const checkoutErrorNoItems = 'No items selected for checkout';
  static const checkoutErrorCard = 'Please enter a valid card number';
  static const checkoutErrorGeneric = 'Could not place order';
  static const orderPlacedTitle = 'Order Placed! 🎉';
  static String orderPlacedNumber(String id) => 'Order #$id';
  static const orderPlacedSubtitle =
      "We'll notify you when your vendor confirms your order";
  static const orderTrackCta = 'Track My Order';
  static const orderContinueShopping = 'Continue Shopping';
  static const couponDetailSave10 = '10% discount applied!';
  static const couponDetailFree500 = '500 DZD discount applied!';
  static const couponDetailWelcome = '15% discount applied!';

  // Product
  static const youMayAlsoLike = 'You May Also Like';
  static const productNotFound = 'Product not found';
  static const productScreenTitle = 'Product';
  static const reviewsTitle = 'Reviews';
  static const customerReviews = 'Customer Reviews';
  static const ratingsWord = 'ratings';
  static const reviewsDotSeparator = ' · ';
  static const reviewsSuffix = ' reviews';
  static const helpfulPrompt = 'Helpful? 👍 ';
  static const specifications = 'Specifications';
  static const description = 'Description';
  static const readMore = 'Read more';
  static const readLess = 'Read less';
  static const quantity = 'Quantity';
  static const stockQuantityRequired = 'Stock quantity *';
  static const chatSeller = 'Chat';
  static const chatSellerSoon = 'Chat with seller — coming soon';
  static const addedToCart = 'Added to cart!';
  static const expressCheckoutSoon = 'Express checkout — coming soon';
  static const buyNow = 'Buy now';
  static const visitStore = 'Visit Store';
  static const verifiedSeller = '✅ Verified Seller';
  static const sellerRatingMid = ' Seller · ';
  static const sellerSalesSuffix = ' sales';
  static const onlyLeftPrefix = 'Only ';
  static const onlyLeftSuffix = ' left!';

  // Listing / vendor
  static const listingTotalListings = 'Total Listings';
  static const listingSoldStat = 'Sold';
  static const listingViews = 'Views';
  static const listingSaves = 'Saves';
  static const listingInquiries = 'Inquiries';
  static const editListing = 'Edit';
  static const editListingMenu = 'Edit Listing';
  static const viewStatsMenu = 'View Stats';
  static const listingStatsHeading = 'Listing stats';
  static const subcategoryPickerPrefix = 'Subcategory — ';
  static const pauseListing = 'Pause';
  static const resumeListing = 'Resume';
  static const listingStats = 'Statistics';
  static const deleteListing = 'Delete';
  static const draft = 'Draft';
  static const active = 'Active';
  static const paused = 'Paused';
  static const sold = 'Sold';
  static const pending = 'Pending';
  static const rejected = 'Rejected';

  // Shared / errors
  static const retry = 'Retry';
  static const errorGeneric = 'Something went wrong';
  static const emptyInbox = 'Nothing here yet';

  // Screen titles (alias nav where aligned)
  static const homeTitle = navHome;
  static const exploreTitle = navExplore;
  static const cartTitle = navCart;
  static const profileTitle = navProfile;
  static const ordersTitle = navOrders;
  static const loginTitle = login;
  static const registerTitle = register;

  // Vendor incoming orders
  static const incomingOrders = 'Incoming Orders';
  static const vendorSearchHint = 'Search by order ID or buyer name';
  static const vendorConfirmAllPending = 'Confirm All Pending';
  static const vendorViewAnalytics = 'View Analytics';
  static const vendorStatPendingOrders = 'Pending Orders';
  static const vendorStatActiveOrders = 'Active Orders';
  static const vendorStatTotalOrders = 'Total Orders';
  static const vendorStatRevenue = 'Revenue';
  static const vendorConfirmAllPendingTitle = 'Confirm all pending orders?';
  static String vendorOrdersConfirmed(int n) => '$n orders confirmed successfully';
  static const vendorSortNewestFirst = 'Newest First';
  static const vendorSortOldestFirst = 'Oldest First';
  static const vendorSortHighestValue = 'Highest Value';
  static const vendorSortNeedsAction = 'Needs Action';
  static const vendorSortBuyerName = 'By Buyer Name A–Z';
  static const vendorNewOrder = 'NEW ORDER';
  static const vendorRejectOrder = 'Reject Order';
  static const vendorConfirmOrder = 'Confirm Order';
  static const vendorConfirmOrderShort = 'Confirm';
  static const vendorMarkProcessing = 'Mark as Processing';
  static const vendorMarkShipped = 'Mark as Shipped';
  static const vendorOrdersEmptyTitle = 'No orders yet';
  static const vendorOrdersEmptySubtitle =
      'When buyers place orders on your listings, they will appear here';
  static const vendorNoStatusOrders = 'No orders for this status';
  static const vendorNoStatusOrdersSubtitle = 'Try another filter or show all orders';
  static const vendorShippingInfoTitle = 'Shipping Information';
  static const vendorViewOnMap = 'View on Map';
  static const vendorCollectOnDelivery = 'Collect on delivery';
  static const vendorRejectTitle = 'Reject this order?';
  static const vendorRejectWarning =
      'This action cannot be undone. The buyer will be notified.';
  static const vendorConfirmRejection = 'Confirm Rejection';
  static const vendorConfirmShipment = 'Confirm Shipment';
  static String vendorLowStockHint(int qty) => '$qty units remaining after this order';
  static const vendorExportOrders = 'Export Orders';
  static const vendorOrderSettings = 'Order Settings';
  static const vendorPrintOrder = 'Print Order';
  static const vendorReportIssue = 'Report Issue';
  static const vendorReasonItemUnavailable = 'Item no longer available';
  static const vendorReasonOutOfStock = 'Out of stock';
  static const vendorReasonCannotDeliver = 'Cannot deliver to buyer location';
  static const vendorReasonSuspicious = 'Suspicious order';
  static const vendorReasonIncorrectPricing = 'Incorrect pricing';
  static const vendorReasonOther = 'Other';
  static const vendorTypeReasonHint = 'Type reason';
  static const vendorTrackingHint = 'XS-TRACK-2024-001';
  static const vendorShippingNoteHint = 'Package handed to courier, estimated 3–5 days';
  static const vendorOrderRejectedSnack = 'Order rejected. Buyer notified.';
  static const vendorOrderConfirmedSnack = 'Order confirmed';
  static const vendorOrderProcessingSnack = 'Order marked as processing';
  static const vendorOrderShippedSnack = 'Order marked as shipped!';
  static const vendorStatusPending = 'Awaiting your confirmation';
  static const vendorStatusConfirmed = 'You confirmed this order';
  static const vendorStatusProcessing = 'Preparing for shipment';
  static const vendorStatusShipped = 'Order is on the way';
  static const vendorStatusDelivered = 'Order delivered successfully';
  static const vendorStatusCancelled = 'This order was cancelled';
  static const vendorStatusRefunded = 'Refunded';
}
