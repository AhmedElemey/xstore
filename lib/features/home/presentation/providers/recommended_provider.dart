import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';

part 'recommended_provider.g.dart';

@riverpod
class Recommended extends _$Recommended {
  @override
  Future<List<ListingEntity>> build() async {
    final result = await ref.watch(getRecommendedUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
