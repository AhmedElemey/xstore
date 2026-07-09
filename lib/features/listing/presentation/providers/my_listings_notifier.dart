import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/listing_entity.dart';
import 'listing_dependencies.dart';
import 'my_listings_state.dart';

part 'my_listings_notifier.g.dart';

/// Vendor “My Listings” screen: fetch, filter, sort, optimistic updates.
@riverpod
class MyListingsNotifier extends _$MyListingsNotifier {
  @override
  MyListingsState build() {
    Future.microtask(fetchListings);
    return const MyListingsState(isLoading: true);
  }

  MyListingsState _withComputed(MyListingsState s) {
    return s.copyWith(
      filteredListings: _filterAndSort(
        s.listings,
        s.selectedFilter,
        s.selectedSort,
        s.searchQuery,
      ),
    );
  }

  Future<void> fetchListings() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getMyListingsUseCaseProvider).call();
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        error: f.toString(),
      ),
      (listings) => state = _withComputed(
        state.copyWith(
          isLoading: false,
          error: null,
          listings: listings,
        ),
      ),
    );
  }

  Future<void> refreshListings() => fetchListings();

  void applyFilter(ListingStatus? filter) {
    state = _withComputed(state.copyWith(selectedFilter: filter));
  }

  void applySort(SortOption sort) {
    state = _withComputed(state.copyWith(selectedSort: sort));
  }

  void toggleViewMode() {
    final next = state.viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
    state = state.copyWith(viewMode: next);
  }

  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setSearchQuery(String query) {
    state = _withComputed(state.copyWith(searchQuery: query));
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> pauseListing(String id) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.active) {
      return;
    }
    await _mutateListingStatus(listing, ListingStatus.paused);
  }

  Future<void> resumeListing(String id) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.paused) {
      return;
    }
    await _mutateListingStatus(listing, ListingStatus.active);
  }

  ListingEntity? _listingById(String id) {
    for (final e in state.listings) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  Future<void> _mutateListingStatus(
    ListingEntity listing,
    ListingStatus nextStatus,
  ) async {
    final beforeMutation = state;
    final optimistic = listing.copyWith(status: nextStatus);
    final optimisticList = beforeMutation.listings
        .map((e) => e.id == listing.id ? optimistic : e)
        .toList();
    state = _withComputed(
      beforeMutation.copyWith(listings: optimisticList, error: null),
    );

    final result = await ref.read(updateListingUseCaseProvider).call(
          id: listing.id,
          titleEn: listing.titleEn.isNotEmpty ? listing.titleEn : listing.title,
          titleAr: listing.titleAr,
          descriptionEn: listing.descriptionEn.isNotEmpty
              ? listing.descriptionEn
              : listing.description,
          descriptionAr: listing.descriptionAr,
          price: listing.price,
          compareAtPrice: listing.compareAtPrice,
          categoryId: listing.categoryId ?? 0,
          subcategoryId: listing.subcategoryId,
          condition: listing.condition ?? ListingCondition.newItem,
          brand: listing.brand,
          stockQuantity: listing.stockQuantity,
          shippingAvailable: listing.shippingAvailable,
          shippingCost: listing.shippingCost,
          location: listing.location,
          attributes: listing.attributes,
          imageUrls: listing.imageUrls,
          status: nextStatus,
        );

    result.fold(
      (f) => state = _withComputed(
        beforeMutation.copyWith(error: f.toString()),
      ),
      (entity) {
        final list = state.listings
            .map((e) => e.id == entity.id ? entity : e)
            .toList();
        state = _withComputed(state.copyWith(listings: list, error: null));
      },
    );
  }

  Future<void> deleteListing(String id) async {
    final snapshot = state;
    final pruned = snapshot.listings.where((e) => e.id != id).toList();
    state = _withComputed(snapshot.copyWith(listings: pruned, error: null));

    final result = await ref.read(deleteListingUseCaseProvider).call(id);
    result.match(
      (failure) {
        state = _withComputed(snapshot.copyWith(error: failure.toString()));
      },
      (_) {},
    );
    if (result.isRight()) {
      await fetchListings();
    }
  }
}

List<ListingEntity> _filterAndSort(
  List<ListingEntity> listings,
  ListingStatus? filter,
  SortOption sort,
  String searchQuery,
) {
  final q = searchQuery.trim().toLowerCase();
  var list = listings.where((e) {
    if (filter != null && e.status != filter) {
      return false;
    }
    if (q.isEmpty) {
      return true;
    }
    return e.title.toLowerCase().contains(q);
  }).toList();

  int compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.compareTo(b);
  }

  int cmp(ListingEntity a, ListingEntity b) {
    switch (sort) {
      case SortOption.newest:
        return -compareDates(a.postedAt, b.postedAt);
      case SortOption.oldest:
        return compareDates(a.postedAt, b.postedAt);
      case SortOption.priceAsc:
        return a.price.compareTo(b.price);
      case SortOption.priceDesc:
        return b.price.compareTo(a.price);
      case SortOption.mostViewed:
        return b.viewCount.compareTo(a.viewCount);
    }
  }

  list.sort(cmp);
  return list;
}
