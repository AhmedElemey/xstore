import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/banner_entity.dart';
import 'home_dependencies.dart';
import 'home_feed_provider.dart';

part 'banners_provider.g.dart';

@riverpod
class Banners extends _$Banners {
  @override
  Future<List<BannerEntity>> build() async {
    final fallback = ref.watch(getBannersUseCaseProvider);
    final feed = await ref.watch(homeFeedProvider.future);
    if (feed != null && feed.banners.isNotEmpty) return feed.banners;
    final result = await fallback.call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
