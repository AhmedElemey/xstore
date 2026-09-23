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
