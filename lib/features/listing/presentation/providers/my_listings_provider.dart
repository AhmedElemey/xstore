import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/listing_entity.dart';
import 'listing_dependencies.dart';

part 'my_listings_provider.g.dart';

@riverpod
class MyListings extends _$MyListings {
  @override
  Future<List<ListingEntity>> build() async {
    final result = await ref.watch(getMyListingsUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> deleteById(String id) async {
    final result = await ref.read(deleteListingUseCaseProvider).call(id);
    result.fold(
      (failure) => throw failure,
      (_) {},
    );
    ref.invalidateSelf();
  }
}
