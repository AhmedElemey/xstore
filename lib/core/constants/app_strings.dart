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

  // Wishlist
  static const wishlistEmptyTitle = 'Your wishlist is empty';
  static const wishlistEmptySubtitle = 'Save items you love to find them later.';

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
}
