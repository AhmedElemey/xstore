import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';

part 'new_arrivals_provider.g.dart';

@riverpod
class NewArrivals extends _$NewArrivals {
  @override
  Future<List<ListingEntity>> build() async {
    final result = await ref.watch(getNewArrivalsUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
