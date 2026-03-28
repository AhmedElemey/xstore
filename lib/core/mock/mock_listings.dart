import '../../features/listing/data/models/listing_model.dart';
import 'mock_images.dart';

/// Compare-at prices for listings that have a discount.
Map<String, double> get mockCompareAtByListingId => {
      for (final r in _catalog)
        if (r.compareAt != null) r.id: r.compareAt!,
    };

/// Per-listing metadata not stored on [ListingModel] (shipping, brand, etc.).
class MockListingMeta {
  const MockListingMeta({
    required this.id,
    this.compareAt,
    this.brand,
    this.shippingAvailable = true,
  });

  final String id;
  final double? compareAt;
  final String? brand;
  final bool shippingAvailable;
}

class _CatalogRow {
  const _CatalogRow({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.compareAt,
    required this.categoryLabel,
    required this.conditionLabel,
    required this.status,
    required this.viewCount,
    required this.saveCount,
    required this.inquiryCount,
    required this.postedDaysAgo,
    required this.imageSeedTens,
    this.brand,
    this.shippingAvailable = true,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final double? compareAt;
  final String categoryLabel;
  final String conditionLabel;
  final String status;
  final int viewCount;
  final int saveCount;
  final int inquiryCount;
  final int postedDaysAgo;
  final int imageSeedTens;
  final String? brand;
  final bool shippingAvailable;

  ListingModel toListingModel() {
    return ListingModel(
      id: id,
      title: title,
      description: description,
      price: price,
      status: status,
      imageUrls: MockImages.productImages(imageSeedTens),
      categoryLabel: categoryLabel,
      conditionLabel: conditionLabel,
      postedAt: DateTime.now().subtract(Duration(days: postedDaysAgo)),
      viewCount: viewCount,
      saveCount: saveCount,
      inquiryCount: inquiryCount,
    );
  }

  MockListingMeta toMeta() => MockListingMeta(
        id: id,
        compareAt: compareAt,
        brand: brand,
        shippingAvailable: shippingAvailable,
      );
}

const List<_CatalogRow> _catalog = [
  _CatalogRow(
    id: 'listing_001',
    title: 'iPhone 15 Pro 256GB',
    description:
        'Natural Titanium iPhone 15 Pro with 256GB storage in excellent condition. '
        'Battery performs reliably for full-day use and the display is pristine. '
        'Includes original box and USB-C cable.',
    price: 185000,
    compareAt: 220000,
    categoryLabel: 'Electronics / Phones',
    conditionLabel: 'Like New',
    status: 'active',
    viewCount: 2100,
    saveCount: 88,
    inquiryCount: 124,
    postedDaysAgo: 12,
    imageSeedTens: 10,
    brand: 'Apple',
  ),
  _CatalogRow(
    id: 'listing_002',
    title: 'Samsung 65" 4K QLED TV',
    description:
        'Immersive 65-inch Samsung QLED with vivid 4K HDR and smart TV apps built in. '
        'Ideal for movies and sports with deep contrast and smooth motion. '
        'Large carton — local pickup recommended; seller can meet in Algiers.',
    price: 145000,
    compareAt: null,
    categoryLabel: 'Electronics / Televisions',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 980,
    saveCount: 40,
    inquiryCount: 87,
    postedDaysAgo: 8,
    imageSeedTens: 20,
    brand: 'Samsung',
    shippingAvailable: false,
  ),
  _CatalogRow(
    id: 'listing_003',
    title: 'Nike Air Max 270',
    description:
        'Comfortable Nike Air Max 270 running-inspired sneakers in black and white. '
        'Breathable mesh upper and visible Air unit for everyday wear. '
        'Great for walking and light training.',
    price: 12500,
    compareAt: 18000,
    categoryLabel: 'Fashion / Shoes',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 3100,
    saveCount: 120,
    inquiryCount: 203,
    postedDaysAgo: 5,
    imageSeedTens: 30,
    brand: 'Nike',
  ),
  _CatalogRow(
    id: 'listing_004',
    title: 'Vintage Leather Sofa 3-Seater',
    description:
        'Warm brown genuine leather three-seater with classic lines and deep seats. '
        'Shows gentle patina consistent with age — no tears or structural issues. '
        'Delivery can be arranged locally only in Oran and surrounding areas.',
    price: 65000,
    compareAt: null,
    categoryLabel: 'Home / Furniture',
    conditionLabel: 'Good',
    status: 'active',
    viewCount: 520,
    saveCount: 18,
    inquiryCount: 31,
    postedDaysAgo: 22,
    imageSeedTens: 40,
    shippingAvailable: false,
  ),
  _CatalogRow(
    id: 'listing_005',
    title: 'MacBook Pro M3 14"',
    description:
        'Apple MacBook Pro 14" with M3 Pro, 18GB RAM, and 512GB SSD. '
        'Liquid Retina XDR display is bright and color-accurate for creative work. '
        'Ideal for developers, designers, and productivity-heavy workflows.',
    price: 280000,
    compareAt: 320000,
    categoryLabel: 'Electronics / Laptops',
    conditionLabel: 'Like New',
    status: 'active',
    viewCount: 1400,
    saveCount: 60,
    inquiryCount: 56,
    postedDaysAgo: 18,
    imageSeedTens: 50,
    brand: 'Apple',
  ),
  _CatalogRow(
    id: 'listing_006',
    title: 'Dyson V15 Vacuum',
    description:
        'Cordless Dyson V15 Detect with strong suction and laser dust detection. '
        'Great for mixed floors and pet hair with up to ~60 minutes runtime. '
        'All tools included as pictured.',
    price: 55000,
    compareAt: 68000,
    categoryLabel: 'Home / Appliances',
    conditionLabel: 'New',
    status: 'pending',
    viewCount: 640,
    saveCount: 22,
    inquiryCount: 44,
    postedDaysAgo: 3,
    imageSeedTens: 60,
    brand: 'Dyson',
  ),
  _CatalogRow(
    id: 'listing_007',
    title: 'Adidas Ultraboost 22',
    description:
        'Adidas Ultraboost 22 in Core Black for responsive road running. '
        'Primeknit upper and Boost midsole provide a smooth, cushioned ride. '
        'Sized EU 41 — verify fit against Adidas sizing charts.',
    price: 9800,
    compareAt: 14500,
    categoryLabel: 'Fashion / Shoes',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 2800,
    saveCount: 95,
    inquiryCount: 178,
    postedDaysAgo: 30,
    imageSeedTens: 70,
    brand: 'Adidas',
  ),
  _CatalogRow(
    id: 'listing_008',
    title: 'Canon EOS R50 Camera Kit',
    description:
        'Compact Canon EOS R50 mirrorless kit with 18-45mm lens for travel and vlogging. '
        '24.2MP sensor with dependable autofocus and 4K video options. '
        'Perfect upgrade from a phone for clearer photos and creative control.',
    price: 98000,
    compareAt: null,
    categoryLabel: 'Electronics / Cameras',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 710,
    saveCount: 25,
    inquiryCount: 29,
    postedDaysAgo: 14,
    imageSeedTens: 80,
    brand: 'Canon',
  ),
  _CatalogRow(
    id: 'listing_009',
    title: 'PS5 Console + 2 Controllers',
    description:
        'PlayStation 5 disc edition with two DualSense controllers, all cables included. '
        'Console runs quietly and loads games fast from the 825GB SSD. '
        'A strong choice for local multiplayer and new-gen titles.',
    price: 95000,
    compareAt: 110000,
    categoryLabel: 'Electronics / Gaming',
    conditionLabel: 'Like New',
    status: 'active',
    viewCount: 5200,
    saveCount: 200,
    inquiryCount: 312,
    postedDaysAgo: 7,
    imageSeedTens: 90,
    brand: 'Sony',
  ),
  _CatalogRow(
    id: 'listing_010',
    title: 'Zara Women Summer Dress',
    description:
        'Light cotton floral summer dress from Zara in size M. '
        'Breathable fabric and relaxed fit for warm days. '
        'Worn once for an event — still looks new.',
    price: 4500,
    compareAt: 7000,
    categoryLabel: "Fashion / Women's",
    conditionLabel: 'New',
    status: 'active',
    viewCount: 1100,
    saveCount: 40,
    inquiryCount: 89,
    postedDaysAgo: 40,
    imageSeedTens: 100,
    brand: 'Zara',
  ),
  _CatalogRow(
    id: 'listing_011',
    title: 'KitchenAid Stand Mixer',
    description:
        'Empire Red KitchenAid tilt-head mixer with 4.7L bowl and 300W motor. '
        'Handles dough and batters with ease for enthusiastic home bakers. '
        'Currently paused while the seller travels.',
    price: 42000,
    compareAt: 52000,
    categoryLabel: 'Home / Kitchen',
    conditionLabel: 'New',
    status: 'paused',
    viewCount: 890,
    saveCount: 33,
    inquiryCount: 67,
    postedDaysAgo: 55,
    imageSeedTens: 110,
    brand: 'KitchenAid',
  ),
  _CatalogRow(
    id: 'listing_012',
    title: 'Yoga Mat + Block Set',
    description:
        'Non-slip TPE yoga mat (6mm) with two foam blocks for home practice. '
        'Lightweight to roll up after sessions and easy to wipe clean. '
        'Great starter bundle for stretching and mobility work.',
    price: 3200,
    compareAt: null,
    categoryLabel: 'Sports / Fitness',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 1600,
    saveCount: 70,
    inquiryCount: 145,
    postedDaysAgo: 2,
    imageSeedTens: 120,
  ),
  _CatalogRow(
    id: 'listing_013',
    title: 'AirPods Pro 2nd Gen',
    description:
        'Apple AirPods Pro (2nd generation) with MagSafe charging case and H2 chip. '
        'Active noise cancellation and transparency modes for daily commuting. '
        'Battery life solid for earbuds in this class.',
    price: 32000,
    compareAt: 38000,
    categoryLabel: 'Electronics / Audio',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 2900,
    saveCount: 110,
    inquiryCount: 201,
    postedDaysAgo: 9,
    imageSeedTens: 130,
    brand: 'Apple',
  ),
  _CatalogRow(
    id: 'listing_014',
    title: 'LEGO Technic Bugatti',
    description:
        'LEGO Technic Bugatti Chiron build with 3599 pieces at 1:8 scale. '
        'Designed for adult collectors; an impressive display centerpiece when finished. '
        'Box opened but bags are sealed.',
    price: 18500,
    compareAt: null,
    categoryLabel: 'Toys / Action Figures',
    conditionLabel: 'New',
    status: 'sold',
    viewCount: 2100,
    saveCount: 150,
    inquiryCount: 38,
    postedDaysAgo: 60,
    imageSeedTens: 140,
    brand: 'LEGO',
  ),
  _CatalogRow(
    id: 'listing_015',
    title: 'Bosch Cordless Drill Set',
    description:
        '18V Bosch cordless drill with charger and 25-piece bit set. '
        'Strong torque for DIY shelving, furniture assembly, and light masonry with care. '
        'Compact enough to keep in a home toolbox.',
    price: 12800,
    compareAt: 16000,
    categoryLabel: 'Automotive / Tools',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 800,
    saveCount: 28,
    inquiryCount: 52,
    postedDaysAgo: 11,
    imageSeedTens: 150,
    brand: 'Bosch',
  ),
  _CatalogRow(
    id: 'listing_016',
    title: 'Parfum Chanel No.5 100ml',
    description:
        'Chanel No.5 Eau de Parfum 100ml — iconic floral aldehyde profile. '
        'Sealed presentation suitable as a gift or personal collection. '
        'Store away from heat and sunlight to preserve the fragrance.',
    price: 28000,
    compareAt: 35000,
    categoryLabel: 'Beauty / Perfume',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 1300,
    saveCount: 55,
    inquiryCount: 93,
    postedDaysAgo: 16,
    imageSeedTens: 160,
    brand: 'Chanel',
  ),
  _CatalogRow(
    id: 'listing_017',
    title: 'Atomic Habits — James Clear',
    description:
        'English paperback of Atomic Habits by James Clear (Penguin, 2018). '
        'Practical frameworks for building good habits and breaking bad ones. '
        'Pages clean with light shelf wear on the cover corners.',
    price: 1200,
    compareAt: null,
    categoryLabel: 'Books / Self-Help',
    conditionLabel: 'Like New',
    status: 'active',
    viewCount: 5400,
    saveCount: 300,
    inquiryCount: 445,
    postedDaysAgo: 44,
    imageSeedTens: 170,
  ),
  _CatalogRow(
    id: 'listing_018',
    title: 'Mountain Bike Trek Marlin 7',
    description:
        'Trek Marlin 7 hardtail with 29" wheels and 24 speeds for trail riding. '
        'Aluminum frame and front suspension to smooth out rough paths. '
        'Listing was rejected by moderation in this mock dataset for demo purposes.',
    price: 85000,
    compareAt: 95000,
    categoryLabel: 'Sports / Cycling',
    conditionLabel: 'Good',
    status: 'rejected',
    viewCount: 400,
    saveCount: 10,
    inquiryCount: 22,
    postedDaysAgo: 73,
    imageSeedTens: 180,
    brand: 'Trek',
    shippingAvailable: false,
  ),
  _CatalogRow(
    id: 'listing_019',
    title: 'Samsung Galaxy Tab S9',
    description:
        'Samsung Galaxy Tab S9 11" AMOLED with 8GB RAM, 128GB storage, and S Pen included. '
        'Bright display for drawing, note-taking, and streaming in HDR where supported. '
        'Thin profile and solid battery life for travel days.',
    price: 78000,
    compareAt: 90000,
    categoryLabel: 'Electronics / Tablets',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 1500,
    saveCount: 48,
    inquiryCount: 71,
    postedDaysAgo: 6,
    imageSeedTens: 190,
    brand: 'Samsung',
  ),
  _CatalogRow(
    id: 'listing_020',
    title: 'Handmade Ceramic Dinner Set',
    description:
        'Ivory white 24-piece ceramic dinnerware set, handmade glaze variations make each piece unique. '
        'Dishwasher safe for easier cleanup after family meals. '
        'Subtle artisan look that suits modern and rustic tables alike.',
    price: 8500,
    compareAt: null,
    categoryLabel: 'Home / Kitchen',
    conditionLabel: 'New',
    status: 'active',
    viewCount: 380,
    saveCount: 12,
    inquiryCount: 18,
    postedDaysAgo: 25,
    imageSeedTens: 200,
  ),
];

List<ListingModel>? _mockListingModelsCache;

/// Cached once so [ListingModel.postedAt] stays stable during a test/session.
List<ListingModel> get mockListingModels =>
    _mockListingModelsCache ??=
        [for (final r in _catalog) r.toListingModel()];

List<MockListingMeta> get mockListingMetaList =>
    [for (final r in _catalog) r.toMeta()];

MockListingMeta? mockMetaForListing(String id) {
  for (final r in _catalog) {
    if (r.id == id) {
      return r.toMeta();
    }
  }
  return null;
}
