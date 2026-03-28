import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/deal_entity.dart';
import 'home_dependencies.dart';

part 'hot_deals_provider.g.dart';

@riverpod
class HotDeals extends _$HotDeals {
  @override
  Future<List<DealEntity>> build() async {
    final result = await ref.watch(getHotDealsUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
