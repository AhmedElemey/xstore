import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/deal_entity.dart';
import 'home_dependencies.dart';

part 'hot_deals_provider.g.dart';

/// Reads its section of the shared [homeFeedProvider].
@riverpod
class HotDeals extends _$HotDeals {
  @override
  Future<List<DealEntity>> build() async =>
      (await ref.watch(homeFeedProvider.future)).hotDeals;
}
