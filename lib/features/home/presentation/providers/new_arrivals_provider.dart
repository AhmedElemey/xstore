import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';
import 'home_feed_provider.dart';

part 'new_arrivals_provider.g.dart';

@riverpod
class NewArrivals extends _$NewArrivals {
  @override
  Future<List<ListingEntity>> build() async {
    final fallback = ref.watch(getNewArrivalsUseCaseProvider);
    final feed = await ref.watch(homeFeedProvider.future);
    if (feed != null && feed.newArrivals.isNotEmpty) return feed.newArrivals;
    final result = await fallback.call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
