import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';
import 'home_feed_provider.dart';

part 'recommended_provider.g.dart';

@riverpod
class Recommended extends _$Recommended {
  @override
  Future<List<ListingEntity>> build() async {
    final fallback = ref.watch(getRecommendedUseCaseProvider);
    final feed = await ref.watch(homeFeedProvider.future);
    if (feed != null && feed.recommended.isNotEmpty) return feed.recommended;
    final result = await fallback.call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
