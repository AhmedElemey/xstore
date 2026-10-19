import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';

part 'new_arrivals_provider.g.dart';

/// Reads its section of the shared [homeFeedProvider].
@riverpod
class NewArrivals extends _$NewArrivals {
  @override
  Future<List<ListingEntity>> build() async =>
      (await ref.watch(homeFeedProvider.future)).newArrivals;
}
