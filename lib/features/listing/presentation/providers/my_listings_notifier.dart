import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../domain/entities/listing_entity.dart';
import 'listing_dependencies.dart';
import 'my_listings_state.dart';

part 'my_listings_notifier.g.dart';

/// Vendor “My Listings” screen: fetch, filter, sort, optimistic updates.
@riverpod
class MyListingsNotifier extends _$MyListingsNotifier {
  // Set when this autoDispose notifier is torn down (screen popped) so
  // in-flight requests don't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  @override
  MyListingsState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
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
    if (_disposed) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getMyListingsUseCaseProvider).call();
    if (_disposed) return;
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

  /// Sends a cancelled listing back for admin review with a corrected
  /// price. Returns null on success, or the server's reason ('' when there
  /// is none). The failure is returned instead of stored on `state.error`:
  /// the resubmit sheet shows it inline, and the screen's error listener
  /// would otherwise toast it a second time behind the sheet.
  Future<String?> resubmitListing(String id, double newPrice) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.cancelled) {
      return '';
    }

    final beforeMutation = state;
    final optimistic = listing.copyWith(
      status: ListingStatus.pending,
      price: newPrice,
      rejectionReason: null,
    );
    final optimisticList = beforeMutation.listings
        .map((e) => e.id == listing.id ? optimistic : e)
        .toList();
    state = _withComputed(
      beforeMutation.copyWith(listings: optimisticList, error: null),
    );

    final result = await ref
        .read(resubmitListingUseCaseProvider)
        .call(id: id, newPrice: newPrice);

    if (_disposed) return '';
    return result.fold(
      (f) {
        state = _withComputed(beforeMutation.copyWith(error: null));
        return f.toString();
      },
      (entity) {
        final list = state.listings
            .map((e) => e.id == entity.id ? entity : e)
            .toList();
        state = _withComputed(state.copyWith(listings: list, error: null));
        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.listingResubmitted,
          properties: {
            AnalyticsProps.itemId: entity.id,
            AnalyticsProps.priceEgp: newPrice,
          },
        );
        return null;
      },
    );
  }

  ListingEntity? _listingById(String id) {
    for (final e in state.listings) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  Future<void> deleteListing(String id) async {
    final snapshot = state;
    final cancelled = snapshot.listings
        .map(
          (e) => e.id == id ? e.copyWith(status: ListingStatus.cancelled) : e,
        )
        .toList();
    state = _withComputed(snapshot.copyWith(listings: cancelled, error: null));

    final result = await ref.read(deleteListingUseCaseProvider).call(id);
    if (_disposed) return;
    result.match(
      (failure) {
        state = _withComputed(snapshot.copyWith(error: failure.toString()));
      },
      (_) {
        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.listingDeleted,
          properties: {AnalyticsProps.itemId: id},
        );
      },
    );
    // Deliberately no fetchListings() refresh here: the listing stays in the
    // list as Cancelled (soft `PUT .../cancel`), so the local update is the
    // final state until the next natural refresh (pull-to-refresh).
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
