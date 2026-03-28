import '../../features/home/data/models/deal_model.dart';
import '../../features/listing/data/models/listing_model.dart';
import 'mock_listings.dart';

DealModel _dealFromListing(ListingModel l) {
  final compare = mockCompareAtByListingId[l.id];
  final discount = (compare != null && compare > 0)
      ? ((compare - l.price) / compare * 100)
      : 0.0;
  return DealModel(
    id: l.id,
    title: l.title,
    price: l.price,
    imageUrl: l.imageUrls.isNotEmpty ? l.imageUrls.first : null,
    discountPercent: discount,
  );
}

/// Hot deals: discounted listings first, highest [DealModel.discountPercent] first.
List<DealModel> get mockHotDealModels {
  final listings = mockListingModels;
  final deals = listings.map<DealModel>(_dealFromListing).toList();
  deals.sort((a, b) {
    final primary = b.discountPercent.compareTo(a.discountPercent);
    if (primary != 0) {
      return primary;
    }
    final la = listings.firstWhere((x) => x.id == a.id);
    final lb = listings.firstWhere((x) => x.id == b.id);
    return (lb.postedAt ?? DateTime(1970))
        .compareTo(la.postedAt ?? DateTime(1970));
  });
  return deals;
}

/// New arrivals: most recently posted first (for feeds that support it).
List<DealModel> get mockNewArrivalDealModels {
  final listings = [...mockListingModels]..sort(
        (a, b) => (b.postedAt ?? DateTime(1970))
            .compareTo(a.postedAt ?? DateTime(1970)),
      );
  return listings.map<DealModel>(_dealFromListing).toList();
}

/// Mock “recommended” slice (first 8 catalog items as deals).
List<DealModel> get mockRecommendedDealModels =>
    mockListingModels.take(8).map<DealModel>(_dealFromListing).toList();

/// Flash sale end time for countdown widgets (relative to app start).
final flashSaleEndTime = DateTime.now().add(
  const Duration(hours: 4, minutes: 23, seconds: 45),
);
