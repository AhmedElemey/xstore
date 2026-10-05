import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../listing/domain/entities/listing_entity.dart';
import 'home_dependencies.dart';

part 'recommended_provider.g.dart';

/// Reads its section of the shared [homeFeedProvider].
@riverpod
class Recommended extends _$Recommended {
  @override
  Future<List<ListingEntity>> build() async =>
      (await ref.watch(homeFeedProvider.future)).recommended;
}
