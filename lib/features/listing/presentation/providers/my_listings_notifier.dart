import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/error/failures.dart';
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

  /// Pauses via the dedicated deactivate endpoint (no multipart body, so
  /// it can't accidentally clear the listing's images — see
  /// `deactivateListingUseCaseProvider`).
  Future<void> pauseListing(String id) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.active) {
      return;
    }
    await _applyOptimisticStatusMutation(
      listing: listing,
      nextStatus: ListingStatus.paused,
      runMutation: () =>
          ref.read(deactivateListingUseCaseProvider).call(id),
    );
  }

  /// Resumes via the generic multipart update — no dedicated "activate"
  /// endpoint is confirmed in the backend contract, unlike pause's
  /// `/deactivate`. Passing `imagePaths: const []` is already the
  /// strongest available mitigation: `_listingFormData` only attaches an
  /// `imageFiles` part per path actually in the list, so an empty list
  /// means the field is fully ABSENT from the multipart body, not present
  /// with an empty value — there is no stronger "don't touch images"
  /// signal this client can send in a multipart PUT. The remaining risk
  /// is purely how the backend interprets an absent `imageFiles` part on
  /// this shared write endpoint, which cannot be resolved without a live
  /// probe or backend confirmation (the hosted backend was down all
  /// session). Flagged in flutter-review SKILL.md — do not "fix" this by
  /// guessing an unconfirmed `/activate` endpoint.
  Future<void> resumeListing(String id) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.paused) {
      return;
    }
    await _applyOptimisticStatusMutation(
      listing: listing,
      nextStatus: ListingStatus.active,
      runMutation: () => ref.read(updateListingUseCaseProvider).call(
            id: listing.id,
            title:
                listing.titleEn.isNotEmpty ? listing.titleEn : listing.title,
            description: listing.descriptionEn.isNotEmpty
                ? listing.descriptionEn
                : listing.description,
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
            imagePaths: const [],
            status: ListingStatus.active,
          ),
    );
  }

  /// Sends a rejected listing back for admin review with a corrected
  /// price. Returns `true` on success so the sheet can close/show a toast.
  Future<bool> resubmitListing(String id, double newPrice) async {
    final listing = _listingById(id);
    if (listing == null || listing.status != ListingStatus.rejected) {
      return false;
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

    if (_disposed) return false;
    var success = false;
    result.fold(
      (f) => state = _withComputed(
        beforeMutation.copyWith(error: f.toString()),
      ),
      (entity) {
        success = true;
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
      },
    );
    return success;
  }

  ListingEntity? _listingById(String id) {
    for (final e in state.listings) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  /// Shared optimistic-update/rollback scaffolding for any single-listing
  /// status mutation. Applies [nextStatus] immediately, runs [runMutation],
  /// then either keeps the server's returned entity or rolls back to the
  /// pre-mutation state and surfaces the failure via `state.error`.
  Future<void> _applyOptimisticStatusMutation({
    required ListingEntity listing,
    required ListingStatus nextStatus,
    required Future<Either<Failure, ListingEntity>> Function() runMutation,
  }) async {
    final beforeMutation = state;
    final optimistic = listing.copyWith(status: nextStatus);
    final optimisticList = beforeMutation.listings
        .map((e) => e.id == listing.id ? optimistic : e)
        .toList();
    state = _withComputed(
      beforeMutation.copyWith(listings: optimisticList, error: null),
    );

    final result = await runMutation();

    if (_disposed) return;
    result.fold(
      (f) => state = _withComputed(
        beforeMutation.copyWith(error: f.toString()),
      ),
      (entity) {
        final list = state.listings
            .map((e) => e.id == entity.id ? entity : e)
            .toList();
        state = _withComputed(state.copyWith(listings: list, error: null));
        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.listingStatusChanged,
          properties: {
            AnalyticsProps.itemId: entity.id,
            AnalyticsProps.status: nextStatus.name,
          },
        );
      },
    );
  }

  Future<void> deleteListing(String id) async {
    final snapshot = state;
    final pruned = snapshot.listings.where((e) => e.id != id).toList();
    state = _withComputed(snapshot.copyWith(listings: pruned, error: null));

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
    // Deliberately no fetchListings() refresh here: the backend has no
    // hard-delete for listings (see ApiEndpoints.apiListingCancel), so a
    // "deleted" listing is really just cancelled server-side. A refetch
    // could pull it straight back into view — and since the cancelled
    // status code isn't confirmed, it would parse to an unmapped/wrong
    // status (defaults to draft) rather than something recognizable.
    // Trusting the optimistic local removal keeps the "removed" UX
    // correct until the next natural refresh (pull-to-refresh).
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
