import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/home_repository.dart';
import 'home_dependencies.dart';

part 'home_feed_provider.g.dart';

/// The single GET /api/home per load. Banners, hot deals, new arrivals and
/// recommended all watch this, so invalidating it refreshes every section
/// with one request.
@riverpod
Future<HomeFeed?> homeFeed(HomeFeedRef ref) {
  return ref.watch(getHomeFeedUseCaseProvider).call();
}
