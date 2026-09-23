import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/deal_entity.dart';
import 'home_dependencies.dart';
import 'home_feed_provider.dart';

part 'hot_deals_provider.g.dart';

@riverpod
class HotDeals extends _$HotDeals {
  @override
  Future<List<DealEntity>> build() async {
    final fallback = ref.watch(getHotDealsUseCaseProvider);
    final feed = await ref.watch(homeFeedProvider.future);
    if (feed != null && feed.hotDeals.isNotEmpty) return feed.hotDeals;
    final result = await fallback.call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
